import 'package:my_dic/features/catalog/internal/infrastructure/drift/query/catalog_ranked_entry_feed_drift_query.dart';
import 'package:my_dic/features/catalog/port/catalog_id.dart';
import 'package:my_dic/features/catalog/port/catalog_word_ref.dart';
import 'package:my_dic/features/catalog/port/model/catalog_ranked_entry.dart';
import 'package:my_dic/features/catalog/port/model/catalog_ranking_entry_ref.dart';

final class CatalogRankedEntryMapper {
  const CatalogRankedEntryMapper();

  CatalogRankedEntry map(CatalogRankedEntryFeedDriftRow row) =>
      CatalogRankedEntry(
        entryRef: CatalogRankingEntryRef.fromSerialized(row.rankingId),
        word: CatalogWordRef(
          catalogId: CatalogId.espJpnMain,
          wordId: row.wordId,
        ),
        rankingNo: row.rankingNo,
        rankedWord: row.rankedWord,
        lemma: row.lemma,
        partsOfSpeech: row.partsOfSpeech,
        hasConjugation: row.hasConjugation,
      );
}
