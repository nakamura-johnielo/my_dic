import 'package:drift/drift.dart';
import 'package:my_dic/core/infrastructure/database/drift/database_provider.dart';
import 'package:my_dic/core/infrastructure/database/drift/tables/esp_jpn/conjugations.dart';
import 'package:my_dic/core/infrastructure/database/drift/tables/esp_jpn/part_of_speech_lists.dart';
import 'package:my_dic/core/infrastructure/database/drift/tables/esp_jpn/word_status.dart';
import 'package:my_dic/core/shared/enums/feature_tag.dart';
import 'package:my_dic/features/ranking/application/query/ranking_query.dart';
import 'package:my_dic/features/ranking/data/data_source/local/rankings_entity.dart';
import 'package:my_dic/features/ranking/data/query/ranking_query_row.dart';

part '../../../../../__generated/features/ranking/data/data_source/local/ranking_dao.g.dart';

@DriftAccessor(
  tables: [Rankings, PartOfSpeechLists, EspJpnWordStatus, EspConjugations],
)
class RankingDao extends DatabaseAccessor<DatabaseProvider>
    with _$RankingDaoMixin {
  RankingDao(super.database);

  /// Fetches one ranking query page plus a look-ahead row.
  Future<List<RankingQueryRow>> fetchRankingQueryPage(
    RankingQuery query,
  ) async {
    final variables = <Variable>[];
    final predicates = <String>[
      'r.ranking_no IS NOT NULL',
      'r.word IS NOT NULL',
      'r.word_origin IS NOT NULL',
      'r.word_id IS NOT NULL',
    ];

    String placeholders(Iterable<String> values) {
      final marks = <String>[];
      for (final value in values) {
        variables.add(Variable.withString(value));
        marks.add('?');
      }
      return marks.join(', ');
    }

    if (query.includedPartOfSpeech.isNotEmpty) {
      predicates.add('''EXISTS (
        SELECT 1 FROM part_of_speech_lists pos
        WHERE pos.word_id = r.word_id AND pos.part_of_speech IN
          (${placeholders(query.includedPartOfSpeech.map((value) => value.wireValue))})
      )''');
    }
    if (query.excludedPartOfSpeech.isNotEmpty) {
      predicates.add('''NOT EXISTS (
        SELECT 1 FROM part_of_speech_lists pos
        WHERE pos.word_id = r.word_id AND pos.part_of_speech IN
          (${placeholders(query.excludedPartOfSpeech.map((value) => value.wireValue))})
      )''');
    }

    final includedStatusTags = query.includedFeatureTags
        .where((tag) => tag != FeatureTag.multiLemma)
        .toList(growable: false);
    final excludedStatusTags = query.excludedFeatureTags
        .where((tag) => tag != FeatureTag.multiLemma)
        .toList(growable: false);
    if (includedStatusTags.isNotEmpty) {
      predicates.add(_statusExistsPredicate(
        tags: includedStatusTags,
        accountId: query.accountId,
        variables: variables,
      ));
    }
    if (excludedStatusTags.isNotEmpty) {
      predicates.add(_statusExistsPredicate(
        tags: excludedStatusTags,
        accountId: query.accountId,
        variables: variables,
        negate: true,
      ));
    }

    final groupByWord =
        query.includedFeatureTags.contains(FeatureTag.multiLemma);
    final selectColumns = groupByWord
        ? '''MIN(r.ranking_no) AS ranking_no, MIN(r.word) AS word,
            MIN(r.word_origin) AS word_origin, r.word_id AS word_id'''
        : '''r.ranking_no AS ranking_no, r.word AS word,
            r.word_origin AS word_origin, r.word_id AS word_id''';
    final where = 'WHERE ${predicates.join(' AND ')}';
    variables
      ..add(Variable.withInt(query.size + 1))
      ..add(Variable.withInt(query.size * query.page));
    final rows = await customSelect(
      '''
        SELECT $selectColumns,
          CASE WHEN EXISTS (
            SELECT 1 FROM conjugations c WHERE c.word_id = r.word_id
          ) THEN 1 ELSE 0 END AS has_conjugation
        FROM rankings r $where
        ${groupByWord ? 'GROUP BY r.word_id' : ''}
        ORDER BY ranking_no LIMIT ? OFFSET ?
      ''',
      variables: variables,
      readsFrom: {
        rankings,
        partOfSpeechLists,
        espJpnWordStatus,
        espConjugations
      },
    ).get();
    return rows
        .map((row) => RankingQueryRow(
              rank: row.read<int?>('ranking_no'),
              rankedWord: row.read<String?>('word'),
              lemma: row.read<String?>('word_origin'),
              wordId: row.read<int?>('word_id'),
              hasConjugation: row.read<int>('has_conjugation') == 1,
            ))
        .toList(growable: false);
  }
}

String _statusExistsPredicate({
  required List<FeatureTag> tags,
  required String accountId,
  required List<Variable> variables,
  bool negate = false,
}) {
  variables.add(Variable.withString(accountId));
  final conditions = <String>[];
  for (final tag in tags) {
    final column = switch (tag) {
      FeatureTag.isLearned => 'is_learned',
      FeatureTag.isBookmarked => 'is_bookmarked',
      FeatureTag.hasNote => 'has_note',
      FeatureTag.myWord => 'my_word',
      FeatureTag.multiLemma => throw ArgumentError.value(tag),
    };
    conditions.add('s.$column = ?');
    variables.add(Variable.withInt(1));
  }
  return '''${negate ? 'NOT ' : ''}EXISTS (
    SELECT 1 FROM word_status s
    WHERE s.word_id = r.word_id AND s.account_id = ?
      AND (${conditions.join(' OR ')})
  )''';
}
