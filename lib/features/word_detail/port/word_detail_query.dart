import 'package:my_dic/features/catalog/port/catalog.dart';

/// Identifies the dictionary content needed for a word-detail page.
final class WordDetailQuery {
  WordDetailQuery({required this.word}) {
    if (word.wordId <= 0) {
      throw ArgumentError.value(word.wordId, 'word.wordId', 'must be positive');
    }
  }

  final CatalogWordRef word;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is WordDetailQuery && other.word == word;

  @override
  int get hashCode => word.hashCode;
}
