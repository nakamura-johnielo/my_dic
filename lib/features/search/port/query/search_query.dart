import 'package:my_dic/features/search/port/model/search_direction.dart';

/// A validated, zero-based page request for Search results.
final class SearchQuery {
  SearchQuery({
    required String text,
    required this.direction,
    required this.page,
    required this.size,
  }) : text = _validatedText(text) {
    _validatePaging(page: page, size: size);
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

  static void _validatePaging({required int page, required int size}) {
    if (page < 0) {
      throw ArgumentError.value(page, 'page', 'must be zero or greater');
    }
    if (size <= 0) {
      throw ArgumentError.value(size, 'size', 'must be greater than zero');
    }
  }
}
