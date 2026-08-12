import 'package:my_dic/features/catalog/port/catalog_id.dart';

/// A validated conjugation search request.
///
/// Conjugations are currently available only in the Spanish-to-Japanese
/// Catalog.
final class CatalogConjugationSearchQuery {
  factory CatalogConjugationSearchQuery({
    required CatalogId catalogId,
    required String text,
    required int page,
    required int size,
  }) {
    if (catalogId != CatalogId.espJpnMain) {
      throw ArgumentError.value(
        catalogId,
        'catalogId',
        'does not support conjugation search',
      );
    }
    final trimmedText = text.trim();
    if (trimmedText.isEmpty) {
      throw ArgumentError.value(text, 'text', 'must not be empty');
    }
    if (page < 0) {
      throw ArgumentError.value(page, 'page', 'must be at least zero');
    }
    if (size <= 0) {
      throw ArgumentError.value(size, 'size', 'must be greater than zero');
    }

    return CatalogConjugationSearchQuery._(
      catalogId: catalogId,
      text: trimmedText,
      page: page,
      size: size,
    );
  }

  const CatalogConjugationSearchQuery._({
    required this.catalogId,
    required this.text,
    required this.page,
    required this.size,
  });

  final CatalogId catalogId;
  final String text;
  final int page;
  final int size;
}
