import 'package:my_dic/features/catalog/port/catalog_word_ref.dart';
import 'package:my_dic/features/catalog/port/model/catalog_part_of_speech.dart';
import 'package:my_dic/features/catalog/port/model/catalog_ranking_entry_ref.dart';

/// One source entry in Catalog's deterministic ranking feed.
final class CatalogRankedEntry {
  CatalogRankedEntry({
    required this.entryRef,
    required this.word,
    required this.rankingNo,
    required this.rankedWord,
    required this.lemma,
    required Iterable<CatalogPartOfSpeech> partsOfSpeech,
    required this.hasConjugation,
  }) : partsOfSpeech = Set.unmodifiable(partsOfSpeech);

  final CatalogRankingEntryRef entryRef;
  final CatalogWordRef word;
  final int rankingNo;
  final String rankedWord;
  final String lemma;
  final Set<CatalogPartOfSpeech> partsOfSpeech;
  final bool hasConjugation;
}
