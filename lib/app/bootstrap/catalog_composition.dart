import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:my_dic/core/di/data/data_di.dart';
import 'package:my_dic/core/di/data/datasource.dart';
import 'package:my_dic/core/di/data/repository_di.dart';
import 'package:my_dic/features/catalog/internal/infrastructure/legacy/legacy_catalog_reader_adapter.dart';
import 'package:my_dic/features/catalog/internal/infrastructure/legacy/legacy_conjugation_reader_adapter.dart';
import 'package:my_dic/features/catalog/internal/infrastructure/legacy/quiz_candidate/legacy_quiz_candidate_enrichment.dart';
import 'package:my_dic/features/catalog/internal/infrastructure/legacy/quiz_candidate/legacy_quiz_candidate_source_adapter.dart';
import 'package:my_dic/features/catalog/port/catalog_reader.dart';
import 'package:my_dic/features/catalog/port/conjugation_reader.dart';
import 'package:my_dic/features/quiz/application/candidate_search/quiz_candidate_source.dart';

/// Composes Catalog's public read ports from the existing legacy repositories.
final catalogReaderProvider = Provider<CatalogReader>((ref) {
  return LegacyCatalogReaderAdapter(
    espJpnRepository: ref.read(esjDictionaryRepositoryProvider),
    jpnEspRepository: ref.read(jpnEspDictionaryRepositoryProvider),
  );
});

/// Composes Catalog's public conjugation port from the legacy repository.
final conjugationReaderProvider = Provider<ConjugationReader>((ref) {
  return LegacyConjugationReaderAdapter(
    ref.read(conjugacionsRepositoryProvider),
  );
});

/// Composes Quiz's candidate lookup port from Catalog's legacy read graph.
///
/// Kept at the application composition boundary so Quiz depends only on its
/// own port and tests can override this provider with a fake source.
final quizCandidateSourceProvider = Provider<QuizCandidateSource>((ref) {
  final conjugations = ref.read(conjugacionDataSourceProvider);
  return LegacyQuizCandidateSourceAdapter(
    conjugations,
    LegacyQuizCandidateEnrichment.withDatabase(
      conjugations,
      ref.read(esjDictionaryDataSourceProvider),
      ref.read(databaseProvider),
    ),
  );
});
