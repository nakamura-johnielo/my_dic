import 'package:my_dic/features/catalog/port/queryport/catalog_conjugation_reader_port.dart';
import 'package:my_dic/features/catalog/port/queryport/catalog_conjugation_search_reader_port.dart';
import 'package:my_dic/features/catalog/port/queryport/catalog_entry_detail_reader_port.dart';
import 'package:my_dic/features/catalog/port/queryport/catalog_entry_summary_reader_port.dart';
import 'package:my_dic/features/catalog/port/queryport/catalog_ranking_reader_port.dart';
import 'package:my_dic/features/catalog/port/queryport/catalog_ranked_entry_feed_reader_port.dart';
import 'package:my_dic/features/catalog/port/queryport/catalog_semantic_entry_detail_reader_port.dart';
import 'package:my_dic/features/catalog/port/queryport/catalog_word_search_reader_port.dart';

/// 1 つのアプリスコープにおける Catalog の公開読み取り機能一式。
final class CatalogQueryPorts {
  const CatalogQueryPorts({
    required this.entryDetail,
    required this.conjugation,
    required this.wordSearch,
    required this.conjugationSearch,
    required this.entrySummary,
    required this.ranking,
    required this.rankedEntries,
    required this.semanticEntryDetail,
  });

  final CatalogEntryDetailQueryPort entryDetail;
  final CatalogConjugationQueryPort conjugation;
  final CatalogWordSearchQueryPort wordSearch;
  final CatalogConjugationSearchQueryPort conjugationSearch;
  final CatalogEntrySummaryQueryPort entrySummary;
  final CatalogRankingQueryPort ranking;
  final CatalogRankedEntryFeedQueryPort rankedEntries;
  final CatalogSemanticEntryDetailQueryPort semanticEntryDetail;
}
