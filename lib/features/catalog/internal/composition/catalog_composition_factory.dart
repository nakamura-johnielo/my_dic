import 'package:my_dic/features/catalog/internal/composition/catalog_dao_providers.dart';
import 'package:my_dic/features/catalog/internal/infrastructure/drift/datasource/conjugation/drift_conjugation_data_source.dart';
import 'package:my_dic/features/catalog/internal/infrastructure/drift/datasource/esp_jpn/drift_esp_jpn_dictionary_data_source.dart';
import 'package:my_dic/features/catalog/internal/infrastructure/drift/datasource/jpn_esp/drift_jpn_esp_dictionary_data_source.dart';
import 'package:my_dic/features/catalog/internal/infrastructure/drift/drift_catalog_reader.dart';
import 'package:my_dic/features/catalog/internal/infrastructure/drift/drift_conjugation_reader.dart';
import 'package:my_dic/features/catalog/internal/infrastructure/drift/reader/drift_catalog_conjugation_search_reader.dart';
import 'package:my_dic/features/catalog/internal/infrastructure/drift/reader/drift_catalog_entry_summary_reader.dart';
import 'package:my_dic/features/catalog/internal/infrastructure/drift/reader/drift_catalog_ranking_reader.dart';
import 'package:my_dic/features/catalog/internal/infrastructure/drift/reader/drift_catalog_word_search_reader.dart';
import 'package:my_dic/features/catalog/internal/infrastructure/drift/repository/drift_conjugation_repository.dart';
import 'package:my_dic/features/catalog/internal/infrastructure/drift/repository/drift_esp_jpn_dictionary_repository.dart';
import 'package:my_dic/features/catalog/internal/infrastructure/drift/repository/drift_jpn_esp_dictionary_repository.dart';
import 'package:my_dic/features/catalog/port/composition_contract.dart';
import 'package:my_dic/features/catalog/port/catalog_read_ports.dart';
import 'package:my_dic/core/di/data/data_di.dart';

/// Catalog-owned assembly of the Drift implementation graph.
CatalogComposition createInternalCatalogComposition(
  CatalogDependencyReaderPort read,
) {
  final espJpnDictionary = EsjDriftDictionaryDataSource(
    read(dictionaryDaoProvider),
    read(exampleDaoProvider),
    read(idiomDaoProvider),
    read(supplementDaoProvider),
  );
  final jpnEspDictionary = JpnEspDriftDictionaryDataSource(
    read(jpnEspDictionaryDaoProvider),
    read(jpnEspExampleDaoProvider),
  );
  final conjugations = ConjugacionDriftDataSource(read(conjugationDaoProvider));
  final database = read(databaseProvider);
  final catalogReaderPort = DriftCatalogReaderPort(
    espJpnRepository: EsjDictionaryRepository(espJpnDictionary),
    jpnEspRepository: JpnEspDictionaryRepository(jpnEspDictionary),
  );
  final conjugationReaderPort = DriftConjugationReaderPort(
    DriftConjugationRepository(conjugations),
  );

  return CatalogComposition(
    readPorts: CatalogReadPorts(
      entryDetail: catalogReaderPort,
      conjugation: conjugationReaderPort,
      wordSearch: DriftCatalogWordSearchReader(database),
      conjugationSearch: DriftCatalogConjugationSearchReader(database),
      entrySummary: DriftCatalogEntrySummaryReader(database),
      ranking: DriftCatalogRankingReader(database),
    ),
    catalogReaderPort: catalogReaderPort,
    conjugationReaderPort: conjugationReaderPort,
  );
}
