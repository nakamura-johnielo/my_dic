import 'package:my_dic/features/catalog/port/catalog_word_ref.dart';
import 'package:my_dic/features/catalog/port/model/catalog_semantic_content.dart';

sealed class CatalogSemanticEntryDetail {
  CatalogSemanticEntryDetail({
    required this.word,
    required Iterable<CatalogSemanticDictionaryEntry> entries,
  }) : entries = List.unmodifiable(entries);

  final CatalogWordRef word;
  final List<CatalogSemanticDictionaryEntry> entries;
}

final class CatalogSemanticEspJpnEntryDetail
    extends CatalogSemanticEntryDetail {
  CatalogSemanticEspJpnEntryDetail({
    required CatalogWordRef word,
    required Iterable<CatalogSemanticEspJpnEntry> entries,
  }) : super(word: word, entries: entries);

  List<CatalogSemanticEspJpnEntry> get espJpnEntries =>
      entries.cast<CatalogSemanticEspJpnEntry>();
}

final class CatalogSemanticJpnEspEntryDetail
    extends CatalogSemanticEntryDetail {
  CatalogSemanticJpnEspEntryDetail({
    required CatalogWordRef word,
    required Iterable<CatalogSemanticJpnEspEntry> entries,
  }) : super(word: word, entries: entries);

  List<CatalogSemanticJpnEspEntry> get jpnEspEntries =>
      entries.cast<CatalogSemanticJpnEspEntry>();
}

sealed class CatalogSemanticDictionaryEntry {
  const CatalogSemanticDictionaryEntry({
    required this.dictionaryId,
    required this.word,
    required this.headword,
    required this.content,
  });

  final int dictionaryId;
  final String word;
  final CatalogSemanticContent headword;
  final CatalogSemanticContent content;
}

final class CatalogSemanticEspJpnEntry
    extends CatalogSemanticDictionaryEntry {
  CatalogSemanticEspJpnEntry({
    required super.dictionaryId,
    required super.word,
    required super.headword,
    required super.content,
    this.origin,
    Iterable<CatalogSemanticEspJpnExample> examples = const [],
    Iterable<CatalogSemanticIdiom> idioms = const [],
    Iterable<CatalogSemanticSupplement> supplements = const [],
  })  : examples = List.unmodifiable(examples),
        idioms = List.unmodifiable(idioms),
        supplements = List.unmodifiable(supplements);

  final CatalogSemanticContent? origin;
  final List<CatalogSemanticEspJpnExample> examples;
  final List<CatalogSemanticIdiom> idioms;
  final List<CatalogSemanticSupplement> supplements;
}

final class CatalogSemanticJpnEspEntry
    extends CatalogSemanticDictionaryEntry {
  CatalogSemanticJpnEspEntry({
    required super.dictionaryId,
    required this.wordId,
    required super.word,
    required super.headword,
    required super.content,
    Iterable<CatalogSemanticJpnEspExample> examples = const [],
  }) : examples = List.unmodifiable(examples);

  final int wordId;
  final List<CatalogSemanticJpnEspExample> examples;
}

final class CatalogSemanticEspJpnExample {
  const CatalogSemanticEspJpnExample({
    required this.exampleId,
    required this.espanol,
    required this.japanese,
  });

  final int exampleId;
  final String espanol;
  final String japanese;
}

final class CatalogSemanticJpnEspExample {
  const CatalogSemanticJpnEspExample({
    required this.exampleId,
    required this.japanese,
    required this.espanol,
    required this.espanolContent,
  });

  final int exampleId;
  final String japanese;
  final String espanol;
  final CatalogSemanticContent espanolContent;
}

final class CatalogSemanticIdiom {
  const CatalogSemanticIdiom({
    required this.idiomId,
    required this.idiom,
    required this.description,
  });

  final int idiomId;
  final String idiom;
  final CatalogSemanticContent description;
}

final class CatalogSemanticSupplement {
  const CatalogSemanticSupplement({
    required this.supplementId,
    required this.content,
  });

  final int supplementId;
  final CatalogSemanticContent content;
}
