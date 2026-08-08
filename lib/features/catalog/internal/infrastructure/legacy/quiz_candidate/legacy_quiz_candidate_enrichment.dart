import 'package:drift/drift.dart';
import 'package:my_dic/core/infrastructure/database/drift/database_provider.dart';
import 'package:my_dic/core/infrastructure/datasource/conjugacion/i_conjugacion_local_datasource.dart';
import 'package:my_dic/core/infrastructure/datasource/esj/i_esj_dictionary_data_source.dart';
import 'package:my_dic/core/shared/errors/app_error.dart';
import 'package:my_dic/core/shared/errors/infrastructure_errors.dart';
import 'package:my_dic/features/catalog/internal/infrastructure/legacy/quiz_candidate/legacy_quiz_candidate_mapper.dart';
import 'package:my_dic/features/quiz/application/candidate_search/quiz_candidate_issue.dart';

final class LegacyQuizCandidateEnrichment {
  LegacyQuizCandidateEnrichment(
    this._conjugations,
    this._dictionary,
    this._rankingLoader,
  );

  factory LegacyQuizCandidateEnrichment.withDatabase(
    IConjugacionLocalDataSource conjugations,
    IEsjDictionaryLocalDataSource dictionary,
    DatabaseProvider database,
  ) =>
      LegacyQuizCandidateEnrichment(
        conjugations,
        dictionary,
        (wordIds) => _loadRankingNos(database, wordIds),
      );

  final IConjugacionLocalDataSource _conjugations;
  final IEsjDictionaryLocalDataSource _dictionary;
  final Future<Map<int, int>> Function(List<int> wordIds) _rankingLoader;

  Future<LegacyQuizCandidateEnrichmentData> load(
    List<int> wordIds,
    List<QuizCandidateIssue> issues,
  ) async {
    if (wordIds.isEmpty) return const LegacyQuizCandidateEnrichmentData();
    final results = await Future.wait([
      _capture('ranking', () => _rankingLoader(wordIds), issues),
      _capture('meaning', () => _loadMeanings(wordIds), issues),
      _capture('starCount', () => _loadStars(wordIds), issues),
    ]);
    return LegacyQuizCandidateEnrichmentData(
      rankings: results[0] as Map<int, int>,
      meanings: results[1] as Map<int, String>,
      starCounts: results[2] as Map<int, int>,
    );
  }

  Future<Map<int, String>> _loadMeanings(List<int> wordIds) async {
    final results = await Future.wait([
      _conjugations.getMeaningsByWordIds(wordIds),
      _dictionary.getFirstContentsByWordIds(wordIds),
    ]);
    final meanings = Map<int, String>.from(results[0]);
    for (final entry in results[1].entries) {
      meanings.putIfAbsent(
        entry.key,
        () => extractLegacyQuizMeaningText(entry.value),
      );
    }
    meanings.removeWhere((_, meaning) => meaning.isEmpty);
    return meanings;
  }

  Future<Map<int, int>> _loadStars(List<int> wordIds) async {
    final headwords = await _dictionary.getFirstHeadwordsByWordIds(wordIds);
    return headwords.map(
      (wordId, headword) =>
          MapEntry(wordId, legacyQuizStarCountFromHeadword(headword)),
    );
  }

  Future<T> _capture<T>(
    String source,
    Future<T> Function() action,
    List<QuizCandidateIssue> issues,
  ) async {
    try {
      return await action();
    } catch (error, stackTrace) {
      issues.add(QuizCandidateIssue(
        source: source,
        error: _asAppError(error, stackTrace),
      ));
      return _emptyValue<T>();
    }
  }
}

final class LegacyQuizCandidateEnrichmentData {
  const LegacyQuizCandidateEnrichmentData({
    this.rankings = const {},
    this.meanings = const {},
    this.starCounts = const {},
  });

  final Map<int, int> rankings;
  final Map<int, String> meanings;
  final Map<int, int> starCounts;
}

Future<Map<int, int>> _loadRankingNos(
  DatabaseProvider database,
  List<int> wordIds,
) async {
  if (wordIds.isEmpty) return const {};
  final variables = wordIds.map(Variable.withInt).toList(growable: false);
  final placeholders = List.filled(wordIds.length, '?').join(', ');
  final rows = await database.customSelect(
    '''
      SELECT r.word_id, r.ranking_no
      FROM rankings r
      WHERE r.word_id IN ($placeholders)
        AND r.ranking_id = (
          SELECT MIN(r2.ranking_id)
          FROM rankings r2
          WHERE r2.word_id = r.word_id
        )
    ''',
    variables: variables,
  ).get();
  return {
    for (final row in rows)
      if (row.read<int?>('word_id') case final wordId?)
        wordId: row.read<int>('ranking_no'),
  };
}

AppError _asAppError(Object error, StackTrace stackTrace) => error is AppError
    ? error
    : DatabaseError(
        message: 'Unable to load quiz candidate enrichment.',
        originalError: error,
        stackTrace: stackTrace,
      );

T _emptyValue<T>() {
  if (T == Map<int, int>) return <int, int>{} as T;
  if (T == Map<int, String>) return <int, String>{} as T;
  throw StateError('No empty value registered for $T.');
}
