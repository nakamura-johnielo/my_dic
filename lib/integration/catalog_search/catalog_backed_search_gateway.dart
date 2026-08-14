import 'package:my_dic/features/catalog/port/catalog.dart';
import 'package:my_dic/features/search/port/search.dart';

/// Pure value adapter from Catalog's public readers to Search's required port.
final class CatalogBackedSearchGateway implements SearchCatalogGateway {
  const CatalogBackedSearchGateway(this._catalog);

  final CatalogQueryPorts _catalog;

  @override
  Future<Result<SearchCatalogPage<SearchPrimaryHit>>> searchPrimary(
    SearchCatalogQuery query,
  ) =>
      _adapt(
        SearchCatalogOperation.primarySearch,
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
        SearchCatalogOperation.conjugationSearch,
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
        SearchCatalogOperation.meanings,
        () => _catalog.entrySummary.readMeanings(words),
        (values) => values.map(
          (word, value) => MapEntry(word, SearchMeaningMetadata(value.meaning)),
        ),
      );

  @override
  Future<Result<Map<CatalogWordRef, SearchFrequencyMetadata>>> readFrequencies(
    Iterable<CatalogWordRef> words,
  ) =>
      _adapt(
        SearchCatalogOperation.frequencies,
        () => _catalog.entrySummary.readHeadwordMetadata(words),
        (values) => values.map(
          (word, value) => MapEntry(
            word,
            SearchFrequencyMetadata(value.frequencyLevel.value),
          ),
        ),
      );

  @override
  Future<Result<Map<CatalogWordRef, SearchRankingMetadata>>> readRankings(
    Iterable<CatalogWordRef> words,
  ) =>
      _adapt(
        SearchCatalogOperation.rankings,
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
  final mood = switch (match.moodTense) {
    CatalogMoodTense.participlePresent => SearchMoodTense.participlePresent,
    CatalogMoodTense.participlePast => SearchMoodTense.participlePast,
    CatalogMoodTense.indicativePresent => SearchMoodTense.indicativePresent,
    CatalogMoodTense.indicativePreterite => SearchMoodTense.indicativePreterite,
    CatalogMoodTense.indicativeImperfect => SearchMoodTense.indicativeImperfect,
    CatalogMoodTense.indicativeFuture => SearchMoodTense.indicativeFuture,
    CatalogMoodTense.indicativeConditional =>
      SearchMoodTense.indicativeConditional,
    CatalogMoodTense.imperative => SearchMoodTense.imperative,
    CatalogMoodTense.subjunctivePresent => SearchMoodTense.subjunctivePresent,
    CatalogMoodTense.subjunctivePast => SearchMoodTense.subjunctivePast,
  };
  final subject = switch (match.subject) {
    null => SearchSubject.yo,
    CatalogSubject.yo => SearchSubject.yo,
    CatalogSubject.tu => SearchSubject.tu,
    CatalogSubject.el => SearchSubject.el,
    CatalogSubject.nosotros => SearchSubject.nosotros,
    CatalogSubject.vosotros => SearchSubject.vosotros,
    CatalogSubject.ellos => SearchSubject.ellos,
  };
  return SearchConjugationMatchKey.values.firstWhere(
    (key) => key.moodTense == mood && key.subject == subject,
  );
}

Future<Result<Target>> _adapt<Source, Target>(
  SearchCatalogOperation operation,
  Future<Result<Source>> Function() read,
  Target Function(Source) convert,
) async {
  try {
    final result = await read();
    if (result case Success<Source>(data: final value)) {
      return Result<Target>.success(convert(value));
    }
    final error = result.errorOrNull!;
    return Result<Target>.failure(
      SearchCatalogGatewayError(
        operation: operation,
        message: error.message,
        originalError: error.originalError ?? error,
        stackTrace: error.stackTrace,
      ),
    );
  } catch (error, stackTrace) {
    return Result<Target>.failure(
      SearchCatalogGatewayError(
        operation: operation,
        message: 'Unable to read Search catalog data.',
        originalError: error,
        stackTrace: stackTrace,
      ),
    );
  }
}
