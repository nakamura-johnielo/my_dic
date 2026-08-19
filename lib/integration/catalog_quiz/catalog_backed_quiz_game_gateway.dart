import 'package:my_dic/core/shared/utils/result.dart';
import 'package:my_dic/features/catalog/port/catalog.dart';
import 'package:my_dic/features/quiz/port/quiz.dart';

/// ゲームの前提条件に対する、CatalogからQuizへの機械的な変換。
///
/// このアダプターは意図的に欠損を解釈したりゲームUIの結果を決定したりしません。
/// それらはQuizアプリケーションのポリシーです。
final class CatalogBackedQuizGameGateway implements QuizGameCatalogGateway {
  const CatalogBackedQuizGameGateway(this._catalog);

  final CatalogQueryPorts _catalog;

  @override
  Future<Result<QuizCatalogPrimaryWord?>> readPrimaryWord(
    CatalogWordRef word,
  ) =>
      _adaptGame(
        operation: 'primaryWord',
        read: () => _catalog.entryDetail.readEntryDetail(word),
        convert: (detail) => QuizCatalogPrimaryWord(
          word: detail.word,
          headword: _headword(detail),
        ),
      );

  @override
  Future<Result<QuizCatalogConjugation?>> readConjugation(
    CatalogWordRef word,
  ) =>
      _adaptGame(
        operation: 'conjugation',
        read: () => _catalog.conjugation.readConjugation(word),
        convert: (value) => value == null ? null : _quizConjugation(value),
      );
}

String _headword(CatalogEntryDetail detail) => switch (detail) {
      EspJpnEntryDetail(:final entries) when entries.isNotEmpty =>
        entries.first.headword ?? entries.first.word,
      JpnEspEntryDetail(:final entries) when entries.isNotEmpty =>
        entries.first.headword ?? entries.first.word,
      _ => detail.word.toString(),
    };

QuizCatalogConjugation _quizConjugation(CatalogConjugation source) =>
    QuizCatalogConjugation(
      word: source.word,
      forms: {
        for (final tense in source.conjugations.entries)
          _quizMoodTense(tense.key): {
            for (final form in tense.value.forms.entries)
              _quizSubject(form.key): form.value,
          },
      },
    );

QuizMoodTense _quizMoodTense(CatalogMoodTense value) =>
    QuizMoodTense.values.byName(value.name);

QuizSubject _quizSubject(CatalogSubject value) =>
    QuizSubject.values.byName(value.name);

Future<Result<Target>> _adaptGame<Source, Target>({
  required String operation,
  required Future<Result<Source>> Function() read,
  required Target Function(Source) convert,
}) async {
  try {
    final result = await read();
    return result.when(
      success: (value) => Result.success(convert(value)),
      failure: (error) => Result.failure(_gameGatewayError(operation, error)),
    );
  } catch (error, stackTrace) {
    return Result.failure(QuizCatalogGatewayError(
      operation: operation,
      message: 'Unable to read Quiz catalog data.',
      originalError: error,
      stackTrace: stackTrace,
    ));
  }
}

QuizCatalogGatewayError _gameGatewayError(String operation, AppError error) =>
    QuizCatalogGatewayError(
      operation: operation,
      message: error.message,
      originalError: error.originalError ?? error,
      stackTrace: error.stackTrace,
    );
