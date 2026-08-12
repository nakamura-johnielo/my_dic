import 'package:my_dic/core/shared/errors/domain_errors.dart';
import 'package:my_dic/core/shared/utils/result.dart';
import 'package:my_dic/features/catalog/port/catalog.dart';
import 'package:my_dic/features/quiz/internal/infrastructure/assets/quiz_game_assets.dart';
import 'package:my_dic/features/quiz/internal/game/domain/i_repository/i_es_en_conjugacion_repository.dart';
import 'package:my_dic/features/quiz/port/game_loader.dart';
import 'package:my_dic/features/quiz/port/model/quiz_game_data.dart';
import 'package:my_dic/features/quiz/port/model/quiz_game_load_result.dart';
import 'package:my_dic/features/quiz/port/model/quiz_game_load_source.dart';
import 'package:my_dic/features/quiz/port/model/quiz_game_query.dart';

// TODO refactor
/// Aggregate facade over the existing Catalog, Drift and bundled-asset graph.
///
/// It intentionally does not assign user-visible meaning to a failure. That
/// policy belongs to B4; this adapter only preserves the source boundary.
final class LoadQuizGameCompatibilityAdapter implements LoadQuizGame {
  LoadQuizGameCompatibilityAdapter({
    required CatalogReaderPort catalogReaderPort,
    required ConjugationReaderPort conjugationReaderPort,
    required IEsEnConjugacionRepository englishConjugationRepository,
    required QuizGameAssets assets,
  })  : _catalogReaderPort = catalogReaderPort,
        _conjugationReaderPort = conjugationReaderPort,
        _englishConjugationRepository = englishConjugationRepository,
        _assets = assets;

  final CatalogReaderPort _catalogReaderPort;
  final ConjugationReaderPort _conjugationReaderPort;
  final IEsEnConjugacionRepository _englishConjugationRepository;
  final QuizGameAssets _assets;

  @override
  Future<QuizGameLoadResult> load(QuizGameQuery query) async {
    // A missing primary word is different from an optional conjugation.  Check
    // it first so a Catalog failure is never accidentally rendered as
    // "no conjugation".
    final detailResult = await _catalogDetail(query);
    if (detailResult is QuizGameLoadFailure) return detailResult;
    if (detailResult is Failure) {
      final failure = detailResult as Failure<Object>;
      if (failure.error is NotFoundError) {
        return const QuizGameLoadResult.notFound();
      }
      return QuizGameLoadResult.failure(
        source: QuizGameLoadSource.primaryCatalog,
        error: failure.error,
      );
    }

    final conjugationResult = await _conjugation(query);
    if (conjugationResult is QuizGameLoadFailure) return conjugationResult;
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
    final englishResult = await _englishConjugation(query);
    if (englishResult is QuizGameLoadFailure) return englishResult;
    if (englishResult is Failure) {
      final failure = englishResult as Failure<Map<String, String>>;
      return QuizGameLoadResult.failure(
        source: QuizGameLoadSource.englishConjugation,
        error: failure.error,
      );
    }
    final english = (englishResult as Success<Map<String, String>>).data;
    return QuizGameLoadResult.ready(QuizGameData(
      conjugation: conjugation,
      englishGuide: guide as Map<String, String>,
      beConjugation: beConjugation as Map<String, Map<String, String>>,
      englishConjugation: english,
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

  Future<Object> _catalogDetail(QuizGameQuery query) async {
    try {
      return await _catalogReaderPort.getEntryDetail(query.word);
    } on Object catch (error) {
      return QuizGameLoadResult.failure(
        source: QuizGameLoadSource.primaryCatalog,
        error: error,
      );
    }
  }

  Future<Object> _conjugation(QuizGameQuery query) async {
    try {
      return await _conjugationReaderPort.getConjugation(query.word);
    } on Object catch (error) {
      return QuizGameLoadResult.failure(
        source: QuizGameLoadSource.catalogConjugation,
        error: error,
      );
    }
  }

  Future<Object> _englishConjugation(QuizGameQuery query) async {
    try {
      return await _englishConjugationRepository.getEnglishConjById(
        query.word.wordId,
      );
    } on Object catch (error) {
      return QuizGameLoadResult.failure(
        source: QuizGameLoadSource.englishConjugation,
        error: error,
      );
    }
  }
}
