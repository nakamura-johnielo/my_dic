/// Identifies a shipped Catalog dataset independently from its Dart enum name.
///
/// The wire value is stable across enum renames. Serialization owners must use
/// [wireValue], rather than [name].
enum CatalogId {
  espJpnMain('esp-jpn-main'),
  jpnEspMain('jpn-esp-main');

  const CatalogId(this.wireValue);

  /// Stable external representation of this Catalog dataset.
  final String wireValue;

  /// Returns the Catalog dataset identified by [value], if it is supported.
  static CatalogId? tryParse(String value) {
    for (final catalogId in CatalogId.values) {
      if (catalogId.wireValue == value) return catalogId;
    }
    return null;
  }
}
