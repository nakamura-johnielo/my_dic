/// Stable identity of one Ranking list item.
///
/// Its serialized value is derived without interpretation from the opaque
/// Catalog ranking-entry identity.
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
