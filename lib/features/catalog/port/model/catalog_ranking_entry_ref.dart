/// 1 つの Catalog ランキングソースエントリの安定した識別子。
///
/// シリアライズ値は Catalog データセットが所有する正の `rankings.ranking_id` である。
/// 利用側はこれを保持・比較できるが、数値からストレージの意味を推測してはならない。
final class CatalogRankingEntryRef {
  const CatalogRankingEntryRef._(this.value);

  factory CatalogRankingEntryRef.fromSerialized(int value) {
    if (value <= 0) {
      throw ArgumentError.value(value, 'value', 'must be positive');
    }
    return CatalogRankingEntryRef._(value);
  }

  final int value;

  int toSerialized() => value;

  @override
  bool operator ==(Object other) =>
      other is CatalogRankingEntryRef && other.value == value;

  @override
  int get hashCode => value.hashCode;

  @override
  String toString() => 'CatalogRankingEntryRef($value)';
}
