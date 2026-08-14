import 'package:my_dic/core/infrastructure/database/drift/database_provider.dart';
import 'package:my_dic/features/catalog/internal/infrastructure/drift/datasource/conjugation/drift_conjugation_data_source.dart';
import 'package:my_dic/features/catalog/internal/infrastructure/drift/datasource/esp_jpn/drift_esp_jpn_dictionary_data_source.dart';
import 'package:my_dic/features/catalog/internal/infrastructure/drift/datasource/jpn_esp/drift_jpn_esp_dictionary_data_source.dart';
import 'package:my_dic/features/catalog/internal/infrastructure/drift/dao/esp_jpn/conjugation_dao.dart';
import 'package:my_dic/features/catalog/internal/infrastructure/drift/dao/esp_jpn/dictionary_dao.dart';
import 'package:my_dic/features/catalog/internal/infrastructure/drift/dao/esp_jpn/example_dao.dart';
import 'package:my_dic/features/catalog/internal/infrastructure/drift/dao/esp_jpn/idiom_dao.dart';
import 'package:my_dic/features/catalog/internal/infrastructure/drift/dao/esp_jpn/supplement_dao.dart';
import 'package:my_dic/features/catalog/internal/infrastructure/drift/dao/jpn_esp/jpn_esp_dictionary_dao.dart';
import 'package:my_dic/features/catalog/internal/infrastructure/drift/dao/jpn_esp/jpn_esp_example_dao.dart';
import 'package:my_dic/features/catalog/internal/infrastructure/drift/drift_catalog_reader.dart';
import 'package:my_dic/features/catalog/internal/infrastructure/drift/drift_conjugation_reader.dart';
import 'package:my_dic/features/catalog/internal/infrastructure/drift/query/drift_catalog_conjugation_search_reader.dart';
import 'package:my_dic/features/catalog/internal/infrastructure/drift/query/drift_catalog_entry_summary_reader.dart';
import 'package:my_dic/features/catalog/internal/infrastructure/drift/query/drift_catalog_ranking_reader.dart';
import 'package:my_dic/features/catalog/internal/infrastructure/drift/query/drift_catalog_ranked_entry_feed_reader.dart';
import 'package:my_dic/features/catalog/internal/infrastructure/drift/query/drift_catalog_semantic_entry_detail_reader.dart';
import 'package:my_dic/features/catalog/internal/infrastructure/drift/query/drift_catalog_word_search_reader.dart';
import 'package:my_dic/features/catalog/internal/infrastructure/drift/repository/drift_conjugation_repository.dart';
import 'package:my_dic/features/catalog/internal/infrastructure/drift/repository/drift_esp_jpn_dictionary_repository.dart';
import 'package:my_dic/features/catalog/internal/infrastructure/drift/repository/drift_jpn_esp_dictionary_repository.dart';
import 'package:my_dic/features/catalog/port/catalog_read_ports.dart';

/// Catalog-owned assembly of the Drift implementation graph.
CatalogQueryPorts createInternalCatalogComposition({
  required DatabaseProvider database,
}) {
  final espJpnDictionary = EspJpnDictionaryDriftDataSource(
    EspjpnDictionaryDao(database),
    EspJpnExampleDao(database),
    EspJpnIdiomDao(database),
    EspJpnSupplementDao(database),
  );
  final jpnEspDictionary = JpnEspDictionaryDriftDataSource(
    JpnEspDictionaryDao(database),
    JpnEspExampleDao(database),
  );
  final conjugations = ConjugationDriftDataSource(ConjugationDao(database));
  final entryDetail = DriftCatalogEntryDetailQueryService(
    espJpnRepository: EspJpnDictionaryRepository(espJpnDictionary),
    jpnEspRepository: JpnEspDictionaryRepository(jpnEspDictionary),
  );
  final conjugation = DriftCatalogConjugationQueryService(
    CatalogConjugationRepository(conjugations),
  );

  return CatalogQueryPorts(
    entryDetail: entryDetail,
    conjugation: conjugation,
    wordSearch: DriftCatalogWordSearchQueryService(database),
    conjugationSearch: DriftCatalogConjugationSearchQueryService(database),
    entrySummary: DriftCatalogEntrySummaryQueryService(database),
    ranking: DriftCatalogRankingQueryService(database),
    rankedEntries: DriftCatalogRankedEntryFeedQueryService(database),
    semanticEntryDetail:
        DriftCatalogSemanticEntryDetailQueryService(entryDetail),
  );
}
