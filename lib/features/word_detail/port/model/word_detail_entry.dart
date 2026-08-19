import 'package:my_dic/features/word_detail/port/model/word_detail_content_block.dart';

/// WordDetail の語彙に投影された、辞書所有の 1 エントリです。
sealed class WordDetailDictionaryEntry {
  const WordDetailDictionaryEntry({
    required this.dictionaryId,
    required this.word,
    required this.headword,
    required this.content,
  });

  final int dictionaryId;
  final String word;
  final WordDetailContent headword;
  final WordDetailContent content;
}

final class WordDetailEspJpnEntry extends WordDetailDictionaryEntry {
  WordDetailEspJpnEntry({
    required super.dictionaryId,
    required super.word,
    required super.headword,
    required super.content,
    this.origin,
    Iterable<WordDetailEspJpnExample> examples = const [],
    Iterable<WordDetailIdiom> idioms = const [],
    Iterable<WordDetailSupplement> supplements = const [],
  })  : examples = List.unmodifiable(examples),
        idioms = List.unmodifiable(idioms),
        supplements = List.unmodifiable(supplements);

  final WordDetailContent? origin;
  final List<WordDetailEspJpnExample> examples;
  final List<WordDetailIdiom> idioms;
  final List<WordDetailSupplement> supplements;
}

final class WordDetailJpnEspEntry extends WordDetailDictionaryEntry {
  WordDetailJpnEspEntry({
    required super.dictionaryId,
    required this.wordId,
    required super.word,
    required super.headword,
    required super.content,
    Iterable<WordDetailJpnEspExample> examples = const [],
  }) : examples = List.unmodifiable(examples);

  final int wordId;
  final List<WordDetailJpnEspExample> examples;
}

final class WordDetailEspJpnExample {
  const WordDetailEspJpnExample({
    required this.exampleId,
    required this.espanol,
    required this.japanese,
  });

  final int exampleId;
  final String espanol;
  final String japanese;
}

final class WordDetailJpnEspExample {
  const WordDetailJpnEspExample({
    required this.exampleId,
    required this.japanese,
    required this.espanol,
    required this.espanolContent,
  });

  final int exampleId;
  final String japanese;
  final String espanol;
  final WordDetailContent espanolContent;
}

final class WordDetailIdiom {
  const WordDetailIdiom({
    required this.idiomId,
    required this.idiom,
    required this.description,
  });

  final int idiomId;
  final String idiom;
  final WordDetailContent description;
}

final class WordDetailSupplement {
  const WordDetailSupplement({
    required this.supplementId,
    required this.content,
  });

  final int supplementId;
  final WordDetailContent content;
}
