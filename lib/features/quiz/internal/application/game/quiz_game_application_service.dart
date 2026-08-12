import 'package:my_dic/core/shared/errors/domain_errors.dart';
import 'package:my_dic/features/quiz/internal/application/game/quiz_game_asset_reader.dart';
import 'package:my_dic/features/quiz/internal/application/game/quiz_game_english_reader.dart';
import 'package:my_dic/features/quiz/port/quiz.dart';

/// Assembles the typed data needed by a Quiz game.
///
/// This deliberately depends only on Quiz-owned seams.  Implementations that
/// read Drift or Flutter assets are supplied later by composition.
final class QuizGameApplicationService implements QuizGameReaderPort {
  QuizGameApplicationService({
    required QuizGameCatalogGateway catalogGateway,
    required QuizGameEnglishReader englishReader,
    required QuizGameAssetReader assetReader,
  })  : _catalogGateway = catalogGateway,
        _englishReader = englishReader,
        _assetReader = assetReader;

  final QuizGameCatalogGateway _catalogGateway;
  final QuizGameEnglishReader _englishReader;
  final QuizGameAssetReader _assetReader;

  @override
  Future<Result<QuizGameLoadOutcome>> load(QuizGameQuery query) async {
    final primary = await _readPrimary(query);
    if (primary is Failure<QuizCatalogPrimaryWord?>) {
      return _failure(QuizGameLoadSource.primaryCatalog, primary.error);
    }
    if ((primary as Success<QuizCatalogPrimaryWord?>).data == null) {
      return const Result.success(QuizGameLoadOutcome.primaryNotFound());
    }

    final catalogConjugation = await _readConjugation(query);
    if (catalogConjugation is Failure<QuizCatalogConjugation?>) {
      return _failure(
        QuizGameLoadSource.catalogConjugation,
        catalogConjugation.error,
      );
    }
    final requiredConjugation =
        (catalogConjugation as Success<QuizCatalogConjugation?>).data;
    if (requiredConjugation == null) {
      return const Result.success(QuizGameLoadOutcome.noConjugation());
    }
    final conjugation = _mapCatalogConjugation(requiredConjugation);

    // Keep the legacy loading order: both bundled assets precede the English
    // database lookup. It keeps source-specific failures stable for the UI.
    final guide = await _readGuide();
    if (guide is Failure<Map<String, String>>) {
      return _failure(QuizGameLoadSource.englishGuide, guide.error);
    }
    final be = await _readBe();
    if (be is Failure<Map<String, Map<String, String>>>) {
      return _failure(QuizGameLoadSource.beConjugation, be.error);
    }
    final english = await _readEnglish(query);
    if (english is Failure<Map<String, String>>) {
      return _failure(QuizGameLoadSource.englishConjugation, english.error);
    }

    return Result.success(QuizGameLoadOutcome.ready(QuizGameData(
      conjugation: conjugation,
      promptGuide:
          _mapPromptGuide((guide as Success<Map<String, String>>).data),
      beConjugation: _mapBeConjugation(
          (be as Success<Map<String, Map<String, String>>>).data),
      englishConjugation: _mapEnglishConjugation(
          (english as Success<Map<String, String>>).data),
    )));
  }

  Future<Result<QuizCatalogPrimaryWord?>> _readPrimary(QuizGameQuery query) =>
      _guard(() => _catalogGateway.readPrimaryWord(query.word));

  Future<Result<QuizCatalogConjugation?>> _readConjugation(
    QuizGameQuery query,
  ) =>
      _guard(() => _catalogGateway.readConjugation(query.word));

  Future<Result<Map<String, String>>> _readGuide() =>
      _guard(_assetReader.readEnglishPromptGuide);

  Future<Result<Map<String, Map<String, String>>>> _readBe() =>
      _guard(_assetReader.readBeConjugation);

  Future<Result<Map<String, String>>> _readEnglish(QuizGameQuery query) =>
      _guard(() => _englishReader.readEnglishConjugation(query.word.wordId));

  Future<Result<T>> _guard<T>(Future<Result<T>> Function() read) async {
    try {
      return await read();
    } on Object catch (error, stackTrace) {
      return Result.failure(_unexpectedError(error, stackTrace));
    }
  }

  Result<QuizGameLoadOutcome> _failure(
          QuizGameLoadSource source, AppError error) =>
      Result.failure(QuizGameLoadError(
        source: source,
        message: error.message,
        code: error.code,
      ));

  AppError _unexpectedError(Object error, StackTrace stackTrace) =>
      BusinessRuleError(
        message: 'Quiz game dependency failed: $error',
        originalError: error,
        stackTrace: stackTrace,
      );

  QuizConjugation _mapCatalogConjugation(
    QuizCatalogConjugation required,
  ) =>
      QuizConjugation(word: required.word, forms: required.forms);

  QuizEnglishConjugation _mapEnglishConjugation(Map<String, String> raw) =>
      QuizEnglishConjugation({
        for (final tense in QuizEnglishMoodTense.values)
          if (raw[_englishTenseKey(tense)] case final value?) tense: value,
      });

  QuizEnglishPromptGuide _mapPromptGuide(Map<String, String> raw) =>
      QuizEnglishPromptGuide({
        for (final tense in QuizMoodTense.values)
          if (raw['MoodTense.${tense.name}'] case final value?) tense: value,
      });

  QuizBeConjugation _mapBeConjugation(
    Map<String, Map<String, String>> raw,
  ) =>
      QuizBeConjugation({
        for (final tense in QuizEnglishMoodTense.values)
          if (raw[_englishTenseKey(tense)] case final bySubject?)
            tense: {
              for (final subject in QuizEnglishSubject.values)
                if (bySubject[_englishSubjectKey(subject)] case final value?)
                  subject: value,
            },
      });

  String _englishTenseKey(QuizEnglishMoodTense tense) =>
      'EnglishMoodTense.${tense.name}';

  String _englishSubjectKey(QuizEnglishSubject subject) =>
      'EnglishSubject.${subject == QuizEnglishSubject.i ? 'I' : subject.name}';
}
