import 'package:my_dic/core/shared/utils/result.dart';
import 'package:my_dic/features/catalog/port/catalog.dart';
import 'package:my_dic/core/shared/errors/app_error.dart';
import 'package:my_dic/features/search/port/catalog_gateway.dart';
import 'package:my_dic/features/search/port/error/search_catalog_gateway_error.dart';
import 'package:my_dic/features/search/port/model/search_conjugation_match_key.dart';
import 'package:my_dic/features/search/port/model/search_direction.dart';

/// Pure value adapter from Catalog's public readers to Search's required port.
final class CatalogBackedSearchGateway implements SearchCatalogGateway {
  const CatalogBackedSearchGateway(this._catalog);

  final CatalogReadPorts _catalog;

  @override
  Future<Result<SearchCatalogPage<SearchPrimaryHit>>> searchPrimary(
    SearchCatalogQuery query,
  ) =>
      _adapt(
        'primary',
        () => _catalog.wordSearch.searchWords(
          CatalogWordSearchQuery(
            catalogId: _catalogId(query.direction),
            text: query.text,
            page: query.page,
            size: query.size,
          ),
        ),
        (page) => SearchCatalogPage(
          items: page.items
              .map(
                (hit) => SearchPrimaryHit(
                  word: hit.word,
                  headword: hit.headword,
                  hasConjugation: hit.hasConjugation,
                ),
              )
              .toList(growable: false),
          hasMore: page.hasMore,
        ),
      );

  @override
  Future<Result<SearchCatalogPage<SearchConjugationHit>>> searchConjugations(
    SearchCatalogQuery query,
  ) =>
      _adapt(
        'conjugation',
        () => _catalog.conjugationSearch.searchConjugations(
          CatalogConjugationSearchQuery(
            catalogId: _catalogId(query.direction),
            text: query.text,
            page: query.page,
            size: query.size,
          ),
        ),
        (page) => SearchCatalogPage(
          items: page.items
              .map(
                (hit) => SearchConjugationHit(
                  word: hit.word,
                  headword: hit.headword,
                  matches: {
                    for (final match in hit.matches.entries)
                      _matchKey(match.key): match.value,
                  },
                ),
              )
              .toList(growable: false),
          hasMore: page.hasMore,
        ),
      );

  @override
  Future<Result<Map<CatalogWordRef, SearchMeaningMetadata>>> readMeanings(
    Iterable<CatalogWordRef> words,
  ) =>
      _adapt(
        'meaning',
        () => _catalog.entrySummary.readMeanings(words),
        (values) => values.map(
          (word, value) => MapEntry(word, SearchMeaningMetadata(value.meaning)),
        ),
      );

  @override
  Future<Result<Map<CatalogWordRef, SearchHeadwordMetadata>>>
      readHeadwordMetadata(Iterable<CatalogWordRef> words) => _adapt(
            'frequency',
            () => _catalog.entrySummary.readHeadwordMetadata(words),
            (values) => values.map(
              (word, value) => MapEntry(
                word,
                SearchHeadwordMetadata(
                  headword: value.headword,
                  frequency: value.frequencyLevel.value,
                ),
              ),
            ),
          );

  @override
  Future<Result<Map<CatalogWordRef, SearchRankingMetadata>>>
      readRankingMetadata(Iterable<CatalogWordRef> words) => _adapt(
            'ranking',
            () => _catalog.ranking.readRankingMetadata(words),
            (values) => values.map(
              (word, value) =>
                  MapEntry(word, SearchRankingMetadata(value.rankingNo)),
            ),
          );
}

CatalogId _catalogId(SearchDirection direction) => switch (direction) {
      SearchDirection.espJpn => CatalogId.espJpnMain,
      SearchDirection.jpnEsp => CatalogId.jpnEspMain,
    };

SearchConjugationMatchKey _matchKey(CatalogConjugationMatch match) {
  final mood = SearchMoodTense.values[match.moodTense.index];
  final subject = match.subject == null
      ? SearchSubject.yo
      : SearchSubject.values[match.subject!.index];
  return SearchConjugationMatchKey.values.firstWhere(
    (key) => key.moodTense == mood && key.subject == subject,
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
      SearchCatalogGatewayError(
        operation: operation,
        message: 'Unable to read Search catalog data.',
        originalError: error,
        stackTrace: stackTrace,
      ),
    );
  }
}

SearchCatalogGatewayError _gatewayError(String operation, AppError error) =>
    SearchCatalogGatewayError(
      operation: operation,
      message: error.message,
      originalError: error.originalError ?? error,
      stackTrace: error.stackTrace,
    );
