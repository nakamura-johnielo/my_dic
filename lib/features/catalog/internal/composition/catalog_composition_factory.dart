import 'package:my_dic/features/catalog/internal/composition/catalog_dao_providers.dart';
import 'package:my_dic/features/catalog/internal/infrastructure/drift/datasource/conjugation/drift_conjugation_data_source.dart';
import 'package:my_dic/features/catalog/internal/infrastructure/drift/datasource/esp_jpn/drift_esp_jpn_dictionary_data_source.dart';
import 'package:my_dic/features/catalog/internal/infrastructure/drift/datasource/esp_jpn/drift_esp_jpn_word_data_source.dart';
import 'package:my_dic/features/catalog/internal/infrastructure/drift/datasource/jpn_esp/drift_jpn_esp_dictionary_data_source.dart';
import 'package:my_dic/features/catalog/internal/infrastructure/drift/datasource/jpn_esp/drift_jpn_esp_word_data_source.dart';
import 'package:my_dic/features/catalog/internal/infrastructure/drift/drift_catalog_reader.dart';
import 'package:my_dic/features/catalog/internal/infrastructure/drift/drift_conjugation_reader.dart';
import 'package:my_dic/features/catalog/internal/infrastructure/drift/repository/drift_conjugation_repository.dart';
import 'package:my_dic/features/catalog/internal/infrastructure/drift/repository/drift_esp_jpn_dictionary_repository.dart';
import 'package:my_dic/features/catalog/internal/infrastructure/drift/repository/drift_jpn_esp_dictionary_repository.dart';
import 'package:my_dic/features/catalog/internal/infrastructure/integration/quiz_candidate/drift_catalog_raw_quiz_candidate_reader.dart';
import 'package:my_dic/features/catalog/internal/infrastructure/integration/search/drift_search_query_repository.dart';
import 'package:my_dic/features/catalog/internal/infrastructure/integration/search/search_query_dao.dart';
import 'package:my_dic/features/catalog/internal/infrastructure/integration/search/catalog_ranking_lookup.dart';
import 'package:my_dic/features/catalog/port/composition_contract.dart';
import 'package:my_dic/core/di/data/data_di.dart';

/// Catalog-owned assembly of the Drift implementation graph.
CatalogComposition createInternalCatalogComposition(
  CatalogDependencyReader read,
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
  final rawSearchReader = DriftCatalogRawSearchReader(
    CatalogRawSearchDao(
      DriftEspJpnWordDataSource(read(wordDaoProvider)),
      JpnEspDriftWordDataSource(read(jpnEspWordDaoProvider)),
      conjugations,
    ),
    espJpnDictionary,
    jpnEspDictionary,
    conjugations,
    DriftCatalogRankingLookup(database),
  );
  final rawQuizCandidateReader = DriftCatalogRawQuizCandidateReader(
    conjugations,
    espJpnDictionary,
    DriftCatalogRankingLookup(database),
  );

  return CatalogComposition(
    catalogReader: DriftCatalogReader(
      espJpnRepository: EsjDictionaryRepository(espJpnDictionary),
      jpnEspRepository: JpnEspDictionaryRepository(jpnEspDictionary),
    ),
    conjugationReader: DriftConjugationReader(
      DriftConjugationRepository(conjugations),
    ),
    rawSearchReader: rawSearchReader,
    rawQuizCandidateReader: rawQuizCandidateReader,
  );
}
