import 'package:my_dic/core/shared/errors/app_error.dart';
import 'package:my_dic/core/shared/utils/result.dart';
import 'package:my_dic/features/catalog/port/catalog.dart';
import 'package:my_dic/features/quiz/port/catalog_gateway.dart';
import 'package:my_dic/features/quiz/port/error/quiz_catalog_gateway_error.dart';

/// Pure value adapter from Catalog readers to Quiz's required port.
final class CatalogBackedQuizGateway implements QuizCatalogGateway {
  const CatalogBackedQuizGateway(this._catalog);

  final CatalogReadPorts _catalog;

  @override
  Future<Result<QuizCatalogPage<QuizConjugationCandidate>>>
      searchConjugationCandidates(QuizCatalogQuery query) => _adapt(
            'conjugation',
            () => _catalog.conjugationSearch.searchConjugations(
              CatalogConjugationSearchQuery(
                catalogId: CatalogId.espJpnMain,
                text: query.text,
                page: query.page,
                size: query.size,
              ),
            ),
            (page) => QuizCatalogPage(
              items: page.items
                  .map(
                    (hit) => QuizConjugationCandidate(
                      word: hit.word,
                      headword: hit.headword,
                    ),
                  )
                  .toList(growable: false),
              hasMore: page.hasMore,
            ),
          );

  @override
  Future<Result<Map<CatalogWordRef, QuizMeaningMetadata>>> readMeanings(
    Iterable<CatalogWordRef> words,
  ) =>
      _adapt(
        'meaning',
        () => _catalog.entrySummary.readMeanings(words),
        (values) => values.map(
          (word, value) => MapEntry(word, QuizMeaningMetadata(value.meaning)),
        ),
      );

  @override
  Future<Result<Map<CatalogWordRef, QuizHeadwordMetadata>>>
      readHeadwordMetadata(Iterable<CatalogWordRef> words) => _adapt(
            'headword',
            () => _catalog.entrySummary.readHeadwordMetadata(words),
            (values) => values.map(
              (word, value) => MapEntry(
                word,
                QuizHeadwordMetadata(
                  headword: value.headword,
                  frequency: value.frequencyLevel.value,
                ),
              ),
            ),
          );

  @override
  Future<Result<Map<CatalogWordRef, QuizRankingMetadata>>> readRankingMetadata(
          Iterable<CatalogWordRef> words) =>
      _adapt(
        'ranking',
        () => _catalog.ranking.readRankingMetadata(words),
        (values) => values.map(
          (word, value) => MapEntry(word, QuizRankingMetadata(value.rankingNo)),
        ),
      );
}

Future<Result<Target>> _adapt<Source, Target>(
  String operation,
  Future<Result<Source>> Function() read,
  Target Function(Source) convert,
) async {
  try {
    final result = await read();
    return result.when(
      success: (value) => Result.success(convert(value)),
      failure: (error) => Result.failure(_gatewayError(operation, error)),
    );
  } catch (error, stackTrace) {
    return Result.failure(
      QuizCatalogGatewayError(
        operation: operation,
        message: 'Unable to read Quiz catalog data.',
        originalError: error,
        stackTrace: stackTrace,
      ),
    );
  }
}

QuizCatalogGatewayError _gatewayError(String operation, AppError error) =>
    QuizCatalogGatewayError(
      operation: operation,
      message: error.message,
      originalError: error.originalError ?? error,
      stackTrace: error.stackTrace,
    );
