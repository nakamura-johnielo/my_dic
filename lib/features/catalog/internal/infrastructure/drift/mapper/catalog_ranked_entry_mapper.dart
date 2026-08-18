import 'package:my_dic/features/catalog/port/catalog_id.dart';
import 'package:my_dic/features/catalog/port/catalog_word_ref.dart';
import 'package:my_dic/features/catalog/port/model/catalog_ranked_entry.dart';
import 'package:my_dic/features/catalog/port/model/catalog_ranking_entry_ref.dart';
import 'package:my_dic/features/catalog/port/model/catalog_part_of_speech.dart';

final class CatalogRankedEntryMapper {
  const CatalogRankedEntryMapper();

  CatalogRankedEntry map({
    required int rankingId,
    required int rankingNo,
    required String rankedWord,
    required String lemma,
    required int wordId,
    required Set<CatalogPartOfSpeech> partsOfSpeech,
    required bool hasConjugation,
  }) =>
      CatalogRankedEntry(
        entryRef: CatalogRankingEntryRef.fromSerialized(rankingId),
        word: CatalogWordRef(
          catalogId: CatalogId.espJpnMain,
          wordId: wordId,
        ),
        rankingNo: rankingNo,
        rankedWord: rankedWord,
        lemma: lemma,
        partsOfSpeech: partsOfSpeech,
        hasConjugation: hasConjugation,
      );
}
