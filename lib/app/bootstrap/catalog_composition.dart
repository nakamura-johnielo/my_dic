import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:my_dic/core/di/data/data_di.dart';
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
import 'package:my_dic/features/catalog/internal/infrastructure/integration/search/drift_search_query_repository.dart';
import 'package:my_dic/features/catalog/internal/infrastructure/integration/search/search_query_dao.dart';
import 'package:my_dic/features/catalog/internal/infrastructure/integration/search/search_ranking_lookup.dart';
import 'package:my_dic/features/catalog/internal/infrastructure/integration/quiz_candidate/drift_quiz_candidate_source.dart';
import 'package:my_dic/features/catalog/internal/infrastructure/integration/quiz_candidate/quiz_candidate_enrichment.dart';
import 'package:my_dic/features/catalog/port/catalog_reader.dart';
import 'package:my_dic/features/catalog/port/conjugation_reader.dart';
import 'package:my_dic/features/quiz/application/candidate_search/quiz_candidate_source.dart';
import 'package:my_dic/features/search/application/query/i_search_query_repository.dart';

/// Composes Catalog's public read port from the Catalog-owned Drift graph.
final catalogReaderProvider = Provider<CatalogReader>((ref) {
  return DriftCatalogReader(
    espJpnRepository: EsjDictionaryRepository(
      EsjDriftDictionaryDataSource(
        ref.read(dictionaryDaoProvider),
        ref.read(exampleDaoProvider),
        ref.read(idiomDaoProvider),
        ref.read(supplementDaoProvider),
      ),
    ),
    jpnEspRepository: JpnEspDictionaryRepository(
      JpnEspDriftDictionaryDataSource(
        ref.read(jpnEspDictionaryDaoProvider),
        ref.read(jpnEspExampleDaoProvider),
      ),
    ),
  );
});

/// Composes Catalog's public conjugation port from the Catalog-owned Drift graph.
final conjugationReaderProvider = Provider<ConjugationReader>((ref) {
  return DriftConjugationReader(
    DriftConjugationRepository(
      ConjugacionDriftDataSource(ref.read(conjugationDaoProvider)),
    ),
  );
});

/// Provides Catalog's adapter for Search's consumer-owned query port.
final searchQueryRepositoryProvider = Provider<ISearchQueryRepository>((ref) {
  final espJpnDictionary = EsjDriftDictionaryDataSource(
    ref.read(dictionaryDaoProvider),
    ref.read(exampleDaoProvider),
    ref.read(idiomDaoProvider),
    ref.read(supplementDaoProvider),
  );
  final jpnEspDictionary = JpnEspDriftDictionaryDataSource(
    ref.read(jpnEspDictionaryDaoProvider),
    ref.read(jpnEspExampleDaoProvider),
  );
  final conjugations =
      ConjugacionDriftDataSource(ref.read(conjugationDaoProvider));
  return DriftSearchQueryRepository(
    SearchQueryDao(
      DriftEspJpnWordDataSource(ref.read(wordDaoProvider)),
      JpnEspDriftWordDataSource(ref.read(jpnEspWordDaoProvider)),
      conjugations,
    ),
    espJpnDictionary,
    jpnEspDictionary,
    conjugations,
    DriftSearchRankingLookup(ref.read(databaseProvider)),
  );
});

/// Composes Catalog's provider-side adapter for Quiz's candidate lookup port.
final quizCandidateSourceProvider = Provider<QuizCandidateSource>((ref) {
  final conjugations =
      ConjugacionDriftDataSource(ref.read(conjugationDaoProvider));
  final dictionary = EsjDriftDictionaryDataSource(
    ref.read(dictionaryDaoProvider),
    ref.read(exampleDaoProvider),
    ref.read(idiomDaoProvider),
    ref.read(supplementDaoProvider),
  );
  return DriftQuizCandidateSource(
    conjugations,
    QuizCandidateEnrichment.withDatabase(
      conjugations,
      dictionary,
      ref.read(databaseProvider),
    ),
  );
});
