import 'package:my_dic/features/catalog/port/model/catalog_ranked_entry.dart';

/// 1 行先読みを含む、決定的な Catalog ランキングソースの断片。
final class CatalogRankedEntryFeed {
  CatalogRankedEntryFeed({
    required Iterable<CatalogRankedEntry> items,
    required this.hasMore,
  }) : items = List.unmodifiable(items);

  final List<CatalogRankedEntry> items;
  final bool hasMore;
}
