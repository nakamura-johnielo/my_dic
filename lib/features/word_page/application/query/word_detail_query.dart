import 'package:my_dic/features/catalog/port/catalog_word_ref.dart';

/// Identifies the dictionary content needed for a word-detail page.
class WordDetailQuery {
  const WordDetailQuery({required this.word});

  final CatalogWordRef word;
}
