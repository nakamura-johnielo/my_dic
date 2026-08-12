import 'package:my_dic/features/catalog/port/reader/catalog_conjugation_reader_port.dart';
import 'package:my_dic/features/catalog/port/reader/catalog_conjugation_search_reader_port.dart';
import 'package:my_dic/features/catalog/port/reader/catalog_entry_detail_reader_port.dart';
import 'package:my_dic/features/catalog/port/reader/catalog_entry_summary_reader_port.dart';
import 'package:my_dic/features/catalog/port/reader/catalog_ranking_reader_port.dart';
import 'package:my_dic/features/catalog/port/reader/catalog_word_search_reader_port.dart';

/// The complete set of public Catalog read capabilities for one app scope.
final class CatalogReadPorts {
  const CatalogReadPorts({
    required this.entryDetail,
    required this.conjugation,
    required this.wordSearch,
    required this.conjugationSearch,
    required this.entrySummary,
    required this.ranking,
  });

  final CatalogEntryDetailReaderPort entryDetail;
  final CatalogConjugationReaderPort conjugation;
  final CatalogWordSearchReaderPort wordSearch;
  final CatalogConjugationSearchReaderPort conjugationSearch;
  final CatalogEntrySummaryReaderPort entrySummary;
  final CatalogRankingReaderPort ranking;
}
