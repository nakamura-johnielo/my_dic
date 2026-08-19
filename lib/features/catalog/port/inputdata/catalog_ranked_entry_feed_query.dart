/// プロバイダー所有の Catalog ランキングソースエントリの断片を読み取る。
final class CatalogRankedEntryFeedQuery {
  CatalogRankedEntryFeedQuery({required this.offset, required this.size}) {
    if (offset < 0) {
      throw ArgumentError.value(offset, 'offset', 'must not be negative');
    }
    if (size <= 0) {
      throw ArgumentError.value(size, 'size', 'must be positive');
    }
  }

  final int offset;
  final int size;
}
