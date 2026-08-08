import 'package:my_dic/features/catalog/port/catalog_id.dart';

/// Immutable public identity for a word in a Catalog dataset.
final class CatalogWordRef {
  const CatalogWordRef({required this.catalogId, required this.wordId})
      : assert(wordId > 0);

  final CatalogId catalogId;
  final int wordId;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is CatalogWordRef &&
          catalogId == other.catalogId &&
          wordId == other.wordId;

  @override
  int get hashCode => Object.hash(catalogId, wordId);

  @override
  String toString() => 'CatalogWordRef(catalogId: $catalogId, wordId: $wordId)';
}
