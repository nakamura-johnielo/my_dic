import 'package:flutter_test/flutter_test.dart';
import 'package:my_dic/features/catalog/port/catalog.dart';

void main() {
  test('ranking entry identity validates and round-trips its stable value', () {
    final ref = CatalogRankingEntryRef.fromSerialized(41);

    expect(ref.toSerialized(), 41);
    expect(ref, CatalogRankingEntryRef.fromSerialized(41));
    expect(() => CatalogRankingEntryRef.fromSerialized(0), throwsArgumentError);
  });

  test('ranked-entry feed query validates provider offset and look-ahead size',
      () {
    final query = CatalogRankedEntryFeedQuery(offset: 20, size: 10);
    expect(query.offset, 20);
    expect(query.size, 10);
    expect(
      () => CatalogRankedEntryFeedQuery(offset: -1, size: 10),
      throwsArgumentError,
    );
    expect(
      () => CatalogRankedEntryFeedQuery(offset: 0, size: 0),
      throwsArgumentError,
    );
  });

  test('ranked entries and feeds defensively copy collections', () {
    final parts = <CatalogPartOfSpeech>[CatalogPartOfSpeech.verb];
    final item = CatalogRankedEntry(
      entryRef: CatalogRankingEntryRef.fromSerialized(1),
      word: const CatalogWordRef(
        catalogId: CatalogId.espJpnMain,
        wordId: 2,
      ),
      rankingNo: 3,
      rankedWord: 'hablo',
      lemma: 'hablar',
      partsOfSpeech: parts,
      hasConjugation: true,
    );
    final source = [item];
    final feed = CatalogRankedEntryFeed(items: source, hasMore: false);
    parts.clear();
    source.clear();

    expect(item.partsOfSpeech, {CatalogPartOfSpeech.verb});
    expect(feed.items.single, same(item));
    expect(() => feed.items.clear(), throwsUnsupportedError);
  });

  test('semantic content owns immutable typed nodes without markup strings',
      () {
    final children = <CatalogContentNode>[const CatalogContentText('meaning')];
    final content = CatalogSemanticContent([
      CatalogContentGroup(
        kind: CatalogContentGroupKind.paragraph,
        roles: const [CatalogContentRole.meaning],
        children: children,
      ),
    ]);
    children.clear();

    final paragraph = content.nodes.single as CatalogContentGroup;
    expect(paragraph.roles, {CatalogContentRole.meaning});
    expect(paragraph.children, hasLength(1));
    expect(() => content.nodes.clear(), throwsUnsupportedError);
    expect(() => paragraph.children.clear(), throwsUnsupportedError);
  });
}
