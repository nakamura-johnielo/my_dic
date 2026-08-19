/// Dart の列挙型名に依存せず、提供済みの Catalog データセットを識別する。
///
/// ワイヤ値は列挙型のリネーム後も安定している。シリアライズの担当は [name] ではなく
/// [wireValue] を使用する必要がある。
enum CatalogId {
  espJpnMain('esp-jpn-main'),
  jpnEspMain('jpn-esp-main');

  const CatalogId(this.wireValue);

  /// この Catalog データセットの安定した外部表現。
  final String wireValue;

  /// サポートされている場合、[value] が識別する Catalog データセットを返す。
  static CatalogId? tryParse(String value) {
    for (final catalogId in CatalogId.values) {
      if (catalogId.wireValue == value) return catalogId;
    }
    return null;
  }
}
