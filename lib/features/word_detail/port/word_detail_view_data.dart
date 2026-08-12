import 'package:my_dic/features/catalog/port/catalog.dart';

/// Complete, screen-ready catalog content for a word-detail page.
sealed class WordDetailViewData {
  const WordDetailViewData(this.word);

  final CatalogWordRef word;
}

class EspJpnWordDetailViewData extends WordDetailViewData {
  EspJpnWordDetailViewData({
    required CatalogWordRef word,
    required List<EspJpnEntry> entries,
    this.conjugation,
  })  : entries = List.unmodifiable(entries),
        super(word);

  /// Full catalog entries, including nested examples, idioms, and supplements.
  final List<EspJpnEntry> entries;
  final CatalogConjugation? conjugation;
}

class JpnEspWordDetailViewData extends WordDetailViewData {
  JpnEspWordDetailViewData({
    required CatalogWordRef word,
    required List<JpnEspEntry> entries,
  })  : entries = List.unmodifiable(entries),
        super(word);

  /// Full catalog entries, including nested examples.
  final List<JpnEspEntry> entries;
}
