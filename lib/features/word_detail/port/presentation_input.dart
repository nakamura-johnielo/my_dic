import 'package:my_dic/features/catalog/port/catalog_word_ref.dart';

/// Ephemeral display data for the word-detail entry.
///
/// [highlight] is intentionally not a route or URL identity field.
final class WordDetailPresentationInput {
  const WordDetailPresentationInput({required this.word, this.highlight});

  final CatalogWordRef word;
  final String? highlight;
}
