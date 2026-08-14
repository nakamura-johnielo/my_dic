import 'package:my_dic/features/catalog/port/model/catalog_ranked_entry.dart';

/// A deterministic Catalog ranking source slice with one-row look-ahead.
final class CatalogRankedEntryFeed {
  CatalogRankedEntryFeed({
    required Iterable<CatalogRankedEntry> items,
    required this.hasMore,
  }) : items = List.unmodifiable(items);

  final List<CatalogRankedEntry> items;
  final bool hasMore;
}
