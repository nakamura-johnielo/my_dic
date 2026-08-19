import 'package:my_dic/core/shared/errors/domain_errors.dart';
import 'package:my_dic/features/quiz/internal/application/game/quiz_game_asset_reader.dart';
import 'package:my_dic/features/quiz/internal/application/game/quiz_game_english_reader.dart';
import 'package:my_dic/features/quiz/port/quiz.dart';

/// Quiz ゲームに必要な型付きデータを組み立てる。
///
/// これは意図的に Quiz 所有の境界にのみ依存する。Drift または Flutter アセットを読み取る
/// 実装は、後からコンポジションで提供される。
final class QuizGameApplicationService implements QuizGameQueryPort {
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

    // レガシーの読み込み順を維持する。両方のバンドル済みアセットを英語データベースの検索より
    // 先に読み込むことで、ソース固有の失敗を UI に対して安定させる。
    final guide = await _readGuide();
    if (guide is Failure<QuizEnglishPromptGuide>) {
      return _failure(QuizGameLoadSource.englishGuide, guide.error);
    }
    final be = await _readBe();
    if (be is Failure<QuizBeConjugation>) {
      return _failure(QuizGameLoadSource.beConjugation, be.error);
    }
    final english = await _readEnglish(query);
    if (english is Failure<QuizEnglishConjugation>) {
      return _failure(QuizGameLoadSource.englishConjugation, english.error);
    }

    return Result.success(QuizGameLoadOutcome.ready(QuizGameData(
      conjugation: conjugation,
      promptGuide: (guide as Success<QuizEnglishPromptGuide>).data,
      beConjugation: (be as Success<QuizBeConjugation>).data,
      englishConjugation: (english as Success<QuizEnglishConjugation>).data,
    )));
  }

  Future<Result<QuizCatalogPrimaryWord?>> _readPrimary(QuizGameQuery query) =>
      _guard(() => _catalogGateway.readPrimaryWord(query.word));

  Future<Result<QuizCatalogConjugation?>> _readConjugation(
    QuizGameQuery query,
  ) =>
      _guard(() => _catalogGateway.readConjugation(query.word));

  Future<Result<QuizEnglishPromptGuide>> _readGuide() =>
      _guard(_assetReader.readEnglishPromptGuide);

  Future<Result<QuizBeConjugation>> _readBe() =>
      _guard(_assetReader.readBeConjugation);

  Future<Result<QuizEnglishConjugation>> _readEnglish(QuizGameQuery query) =>
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
}
