import 'package:my_dic/features/search/port/model/search_direction.dart';

/// Validated provider-neutral input for Search's Catalog gateway.
final class SearchCatalogQuery {
  SearchCatalogQuery({
    required String text,
    required this.direction,
    required this.page,
    required this.size,
  }) : text = _validatedText(text) {
    if (page < 0) {
      throw ArgumentError.value(page, 'page', 'must be zero or greater');
    }
    if (size <= 0) {
      throw ArgumentError.value(size, 'size', 'must be greater than zero');
    }
  }

  final String text;
  final SearchDirection direction;
  final int page;
  final int size;

  static String _validatedText(String value) {
    final text = value.trim();
    if (text.isEmpty) {
      throw ArgumentError.value(value, 'text', 'must not be blank');
    }
    return text;
  }
}
