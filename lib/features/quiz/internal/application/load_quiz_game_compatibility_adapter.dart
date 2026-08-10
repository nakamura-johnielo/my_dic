import 'package:my_dic/core/infrastructure/database/drift/database_provider.dart';
import 'package:my_dic/core/shared/enums/conjugacion/mood_tense.dart';
import 'package:my_dic/core/shared/utils/result.dart';
import 'package:my_dic/features/catalog/port/conjugation_reader.dart';
import 'package:my_dic/features/catalog/port/model/catalog_conjugation.dart';
import 'package:my_dic/features/quiz/internal/infrastructure/assets/quiz_game_assets.dart';
import 'package:my_dic/features/quiz/internal/infrastructure/drift/dao/es_en_conjugacion_dao.dart';
import 'package:my_dic/features/quiz/port/game_loader.dart';
import 'package:my_dic/features/quiz/port/model/quiz_game_data.dart';
import 'package:my_dic/features/quiz/port/model/quiz_game_load_result.dart';
import 'package:my_dic/features/quiz/port/model/quiz_game_load_source.dart';
import 'package:my_dic/features/quiz/port/model/quiz_game_query.dart';

/// Aggregate facade over the existing Catalog, Drift and bundled-asset graph.
///
/// It intentionally does not assign user-visible meaning to a failure. That
/// policy belongs to B4; this adapter only preserves the source boundary.
final class LoadQuizGameCompatibilityAdapter implements LoadQuizGame {
  LoadQuizGameCompatibilityAdapter({
    required ConjugationReader conjugationReader,
    required EsEnConjugacionDao englishConjugationDao,
    required QuizGameAssets assets,
  })  : _conjugationReader = conjugationReader,
        _englishConjugationDao = englishConjugationDao,
        _assets = assets;

  final ConjugationReader _conjugationReader;
  final EsEnConjugacionDao _englishConjugationDao;
  final QuizGameAssets _assets;

  @override
  Future<QuizGameLoadResult> load(QuizGameQuery query) async {
    final conjugationResult =
        await _conjugationReader.getConjugation(query.word);
    if (conjugationResult is Failure) {
      final failure = conjugationResult as Failure<CatalogConjugation?>;
      return QuizGameLoadResult.failure(
        source: QuizGameLoadSource.catalogConjugation,
        error: failure.error,
      );
    }
    final conjugation =
        (conjugationResult as Success<CatalogConjugation?>).data;
    if (conjugation == null) return const QuizGameLoadResult.noConjugation();

    final guide = await _load(
      _assets.loadEnglishGuide,
      QuizGameLoadSource.englishGuide,
    );
    if (guide is QuizGameLoadFailure) return guide;
    final beConjugation = await _load(
      _assets.loadBeConjugation,
      QuizGameLoadSource.beConjugation,
    );
    if (beConjugation is QuizGameLoadFailure) return beConjugation;
    final english = await _load(
      () => _englishConjugationDao.getEnglishConjById(query.word.wordId),
      QuizGameLoadSource.englishConjugation,
    );
    if (english is QuizGameLoadFailure) return english;
    if (english == null) return const QuizGameLoadResult.notFound();
    return QuizGameLoadResult.ready(QuizGameData(
      conjugation: conjugation,
      englishGuide: guide as Map<String, String>,
      beConjugation: beConjugation as Map<String, Map<String, String>>,
      englishConjugation:
          _englishConjugation(english as EsEnConjugacionTableData),
    ));
  }

  Future<Object?> _load<T>(
    Future<T> Function() operation,
    QuizGameLoadSource source,
  ) async {
    try {
      return await operation();
    } on Object catch (error) {
      return QuizGameLoadResult.failure(source: source, error: error);
    }
  }

  Map<String, String> _englishConjugation(EsEnConjugacionTableData row) => {
        EnglishMoodTense.participlePresent.toString(): row.presentP ?? 'V-ing',
        EnglishMoodTense.participlePast.toString(): row.pastP ?? 'V-en',
        EnglishMoodTense.indicativePresent.toString(): row.english ?? 'V',
        EnglishMoodTense.indicativePresent3rd.toString():
            row.present3rd ?? 'Vs',
        EnglishMoodTense.indicativePast.toString(): row.past ?? 'V-ed',
      };
}
