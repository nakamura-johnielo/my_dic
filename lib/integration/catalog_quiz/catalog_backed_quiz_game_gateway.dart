import 'package:my_dic/core/shared/utils/result.dart';
import 'package:my_dic/features/catalog/port/catalog.dart';
import 'package:my_dic/features/quiz/port/quiz.dart';

/// Mechanical Catalog-to-Quiz conversion for game prerequisites.
///
/// This adapter deliberately does not interpret absence or decide game UI
/// outcomes; those are Quiz application policy.
final class CatalogBackedQuizGameGateway implements QuizGameCatalogGateway {
  const CatalogBackedQuizGameGateway(this._catalog);

  final CatalogReadPorts _catalog;

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
