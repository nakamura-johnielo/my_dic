/// 1 つの Ranking リスト項目の安定した識別子。
///
/// シリアライズ値は、不透明な Catalog ランキングエントリ識別子から解釈を加えずに導出される。
final class RankingItemId {
  const RankingItemId._(this.value);

  factory RankingItemId.fromSerialized(int value) {
    if (value <= 0) {
      throw ArgumentError.value(value, 'value', 'must be positive');
    }
    return RankingItemId._(value);
  }

  final int value;

  int toSerialized() => value;

  @override
  bool operator ==(Object other) =>
      other is RankingItemId && other.value == value;

  @override
  int get hashCode => value.hashCode;

  @override
  String toString() => 'RankingItemId($value)';
}
