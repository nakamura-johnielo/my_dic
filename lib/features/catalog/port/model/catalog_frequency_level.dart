/// A non-negative frequency level assigned by a Catalog dataset.
///
/// Shipped Catalog data normally uses levels 0 through 3. Larger values are
/// retained so the public contract remains forward-compatible with new data.
final class CatalogFrequencyLevel {
  factory CatalogFrequencyLevel(int value) {
    if (value < 0) {
      throw ArgumentError.value(value, 'value', 'must not be negative');
    }
    return CatalogFrequencyLevel._(value);
  }

  const CatalogFrequencyLevel._(this.value);

  final int value;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is CatalogFrequencyLevel && value == other.value;

  @override
  int get hashCode => value.hashCode;

  @override
  String toString() => 'CatalogFrequencyLevel($value)';
}
