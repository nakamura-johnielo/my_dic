import 'package:my_dic/features/catalog/port/catalog.dart';

/// Identifies the dictionary content needed for a word-detail page.
class WordDetailQuery {
  const WordDetailQuery({required this.word});

  final CatalogWordRef word;
}
