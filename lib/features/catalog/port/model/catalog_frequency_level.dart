/// Catalog データセットが割り当てる、負ではない頻度レベル。
///
/// 提供済みの Catalog データは通常レベル 0 から 3 を使用する。公開契約を新しいデータと
/// 前方互換に保つため、より大きい値も保持される。
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
