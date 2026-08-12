import 'package:my_dic/core/shared/utils/result.dart';
import 'package:my_dic/features/catalog/port/catalog.dart';
import 'package:my_dic/features/quiz/port/quiz.dart';

/// Mechanical Catalog-to-Quiz conversion for candidate reads.
///
/// Query validation, candidate selection and enrichment policy remain owned by
/// the Quiz application layer.
final class CatalogBackedQuizCandidateGateway
    implements QuizCandidateCatalogGateway {
  const CatalogBackedQuizCandidateGateway(this._catalog);

  final CatalogReadPorts _catalog;

  @override
  Future<Result<QuizCatalogCandidatePage>> searchConjugationCandidates(
    QuizCatalogCandidateQuery query,
  ) =>
      _adapt(
        operation: 'conjugationCandidates',
        read: () => _catalog.conjugationSearch.searchConjugations(
          CatalogConjugationSearchQuery(
            catalogId: CatalogId.espJpnMain,
            text: query.text,
            page: query.page,
            size: query.size,
          ),
        ),
        convert: (page) => QuizCatalogCandidatePage(
          items: page.items
              .map((hit) => QuizCatalogCandidate(
                    word: hit.word,
                    headword: hit.headword,
                  ))
              .toList(growable: false),
          hasMore: page.hasMore,
        ),
      );

  @override
  Future<Result<Map<CatalogWordRef, QuizCatalogMeaning>>> readMeanings(
    Iterable<CatalogWordRef> words,
  ) =>
      _adapt(
        operation: 'meanings',
        read: () => _catalog.entrySummary.readMeanings(words),
        convert: (values) => {
          for (final entry in values.entries)
            entry.key: QuizCatalogMeaning(entry.value.meaning),
        },
      );

  @override
  Future<Result<Map<CatalogWordRef, QuizCatalogHeadword>>> readHeadwords(
    Iterable<CatalogWordRef> words,
  ) =>
      _adapt(
        operation: 'headwords',
        read: () => _catalog.entrySummary.readHeadwordMetadata(words),
        convert: (values) => {
          for (final entry in values.entries)
            entry.key: QuizCatalogHeadword(
              text: entry.value.headword,
              frequency: entry.value.frequencyLevel.value,
            ),
        },
      );

  @override
  Future<Result<Map<CatalogWordRef, QuizCatalogRanking>>> readRankings(
    Iterable<CatalogWordRef> words,
  ) =>
      _adapt(
        operation: 'rankings',
        read: () => _catalog.ranking.readRankingMetadata(words),
        convert: (values) => {
          for (final entry in values.entries)
            entry.key: QuizCatalogRanking(entry.value.rankingNo),
        },
      );
}

Future<Result<Target>> _adapt<Source, Target>({
  required String operation,
  required Future<Result<Source>> Function() read,
  required Target Function(Source) convert,
}) async {
  try {
    final result = await read();
    return result.when(
      success: (value) => Result.success(convert(value)),
      failure: (error) => Result.failure(_quizGatewayError(operation, error)),
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

QuizCatalogGatewayError _quizGatewayError(String operation, AppError error) =>
    QuizCatalogGatewayError(
      operation: operation,
      message: error.message,
      originalError: error.originalError ?? error,
      stackTrace: error.stackTrace,
    );
