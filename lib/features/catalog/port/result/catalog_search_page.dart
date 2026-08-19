/// Catalog 検索結果の不変な 1 ページ。
///
/// [hasMore] は、通常 `query.size + 1` 行を読み取ることで、リーダーが [items] の先に
/// 少なくとも 1 行を確認した場合にのみ true となる。
final class CatalogSearchPage<T> {
  CatalogSearchPage({required List<T> items, required this.hasMore})
      : items = List.unmodifiable(items);

  final List<T> items;
  final bool hasMore;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is CatalogSearchPage<T> &&
          hasMore == other.hasMore &&
          _listEquals(items, other.items);

  @override
  int get hashCode => Object.hash(Object.hashAll(items), hasMore);
}

bool _listEquals<T>(List<T> first, List<T> second) {
  if (identical(first, second)) return true;
  if (first.length != second.length) return false;
  for (var index = 0; index < first.length; index++) {
    if (first[index] != second[index]) return false;
  }
  return true;
}
