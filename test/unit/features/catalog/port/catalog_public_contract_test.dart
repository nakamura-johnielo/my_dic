import 'package:flutter_test/flutter_test.dart';
import 'package:my_dic/features/catalog/port/catalog.dart';

void main() {
  group('Catalog queries', () {
    test('trim only surrounding whitespace and retain paging values', () {
      final query = CatalogWordSearchQuery(
        catalogId: CatalogId.jpnEspMain,
        text: '  Á かな  ',
        page: 2,
        size: 20,
      );

      expect(query.catalogId, CatalogId.jpnEspMain);
      expect(query.text, 'Á かな');
      expect(query.page, 2);
      expect(query.size, 20);
    });

    test('reject invalid text and paging synchronously', () {
      expect(
        () => CatalogWordSearchQuery(
          catalogId: CatalogId.espJpnMain,
          text: ' \n\t ',
          page: 0,
          size: 10,
        ),
        throwsArgumentError,
      );
      expect(
        () => CatalogWordSearchQuery(
          catalogId: CatalogId.espJpnMain,
          text: 'word',
          page: -1,
          size: 10,
        ),
        throwsArgumentError,
      );
      expect(
        () => CatalogWordSearchQuery(
          catalogId: CatalogId.espJpnMain,
          text: 'word',
          page: 0,
          size: 0,
        ),
        throwsArgumentError,
      );
    });

    test('conjugation search validates the Catalog capability', () {
      final query = CatalogConjugationSearchQuery(
        catalogId: CatalogId.espJpnMain,
        text: ' hablar ',
        page: 0,
        size: 10,
      );
      expect(query.text, 'hablar');

      expect(
        () => CatalogConjugationSearchQuery(
          catalogId: CatalogId.jpnEspMain,
          text: '話す',
          page: 0,
          size: 10,
        ),
        throwsArgumentError,
      );
    });
  });

  group('Catalog public values', () {
    test('frequency is non-negative without imposing a maximum', () {
      expect(CatalogFrequencyLevel(0).value, 0);
      expect(CatalogFrequencyLevel(3).value, 3);
      expect(CatalogFrequencyLevel(4).value, 4);
      expect(() => CatalogFrequencyLevel(-1), throwsArgumentError);
      expect(CatalogFrequencyLevel(2), CatalogFrequencyLevel(2));
    });

    test('search pages and match maps are immutable', () {
      final items = [
        const CatalogWordSearchHit(
          word: CatalogWordRef(
            catalogId: CatalogId.espJpnMain,
            wordId: 1,
          ),
          headword: 'hablar',
          hasConjugation: true,
        ),
      ];
      final page = CatalogSearchPage(items: items, hasMore: true);
      items.clear();

      expect(page.items, hasLength(1));
      expect(page.hasMore, isTrue);
      expect(() => page.items.clear(), throwsUnsupportedError);

      final matches = {
        const CatalogConjugationMatch(
          moodTense: CatalogMoodTense.indicativePresent,
          subject: CatalogSubject.yo,
        ): 'hablo',
      };
      final hit = CatalogConjugationSearchHit(
        word: const CatalogWordRef(
          catalogId: CatalogId.espJpnMain,
          wordId: 1,
        ),
        headword: 'hablar',
        matches: matches,
      );
      matches.clear();

      expect(hit.matches.values, ['hablo']);
      expect(() => hit.matches.clear(), throwsUnsupportedError);
    });

    test('read errors have stable Catalog classifications', () {
      const word = CatalogWordRef(
        catalogId: CatalogId.espJpnMain,
        wordId: 9,
      );

      expect(
        CatalogEntryNotFoundError(word: word),
        isA<CatalogReadError>(),
      );
      expect(
        const CatalogDataUnavailableError().code,
        'CATALOG_DATA_UNAVAILABLE',
      );
      expect(
        const CatalogDataCorruptedError().code,
        'CATALOG_DATA_CORRUPTED',
      );
      expect(
        const CatalogUnexpectedReadError().code,
        'CATALOG_UNEXPECTED_READ',
      );
    });
  });

  test('CatalogReadPorts bundles every dedicated public reader', () {
    final entryDetail = _EntryDetailReader();
    final conjugation = _ConjugationReader();
    final wordSearch = _WordSearchReader();
    final conjugationSearch = _ConjugationSearchReader();
    final entrySummary = _EntrySummaryReader();
    final ranking = _RankingReader();

    final ports = CatalogReadPorts(
      entryDetail: entryDetail,
      conjugation: conjugation,
      wordSearch: wordSearch,
      conjugationSearch: conjugationSearch,
      entrySummary: entrySummary,
      ranking: ranking,
    );

    expect(ports.entryDetail, same(entryDetail));
    expect(ports.conjugation, same(conjugation));
    expect(ports.wordSearch, same(wordSearch));
    expect(ports.conjugationSearch, same(conjugationSearch));
    expect(ports.entrySummary, same(entrySummary));
    expect(ports.ranking, same(ranking));
  });
}

final class _EntryDetailReader implements CatalogEntryDetailReaderPort {
  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

final class _ConjugationReader implements CatalogConjugationReaderPort {
  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

final class _WordSearchReader implements CatalogWordSearchReaderPort {
  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

final class _ConjugationSearchReader
    implements CatalogConjugationSearchReaderPort {
  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

final class _EntrySummaryReader implements CatalogEntrySummaryReaderPort {
  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

final class _RankingReader implements CatalogRankingReaderPort {
  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}
