/// Stable identity of one Catalog ranking source entry.
///
/// The serialized value is the positive `rankings.ranking_id` owned by the
/// Catalog dataset. Consumers may preserve and compare it, but must not infer
/// storage semantics from the number.
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
