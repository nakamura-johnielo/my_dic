import 'package:my_dic/features/catalog/port/catalog_id.dart';

/// 1 つの Catalog データセットに対する、検証済みのページベース単語検索リクエスト。
final class CatalogWordSearchQuery {
  factory CatalogWordSearchQuery({
    required CatalogId catalogId,
    required String text,
    required int page,
    required int size,
  }) {
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

    return CatalogWordSearchQuery._(
      catalogId: catalogId,
      text: trimmedText,
      page: page,
      size: size,
    );
  }

  const CatalogWordSearchQuery._({
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
