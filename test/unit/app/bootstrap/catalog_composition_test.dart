import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:my_dic/app/bootstrap/catalog_composition.dart';
import 'package:my_dic/core/shared/utils/result.dart';
import 'package:my_dic/features/catalog/internal/infrastructure/drift/drift_catalog_reader.dart';
import 'package:my_dic/features/catalog/internal/infrastructure/drift/drift_conjugation_reader.dart';
import 'package:my_dic/features/catalog/internal/infrastructure/integration/search/drift_search_query_repository.dart';
import 'package:my_dic/features/catalog/internal/infrastructure/integration/quiz_candidate/drift_quiz_candidate_source.dart';
import 'package:my_dic/features/quiz/application/candidate_search/quiz_candidate_page.dart';
import 'package:my_dic/features/quiz/application/candidate_search/quiz_candidate_query.dart';
import 'package:my_dic/features/quiz/application/candidate_search/quiz_candidate_source.dart';
import 'package:my_dic/features/search/application/query/i_search_query_repository.dart';
import 'package:my_dic/features/search/application/query/search_query.dart';
import 'package:my_dic/features/search/application/query/search_result_page.dart';

void main() {
  test('resolves Catalog readers from the Catalog-owned Drift graph', () {
    final container = ProviderContainer();
    addTearDown(container.dispose);

    expect(container.read(catalogReaderProvider), isA<DriftCatalogReader>());
    expect(
      container.read(conjugationReaderProvider),
      isA<DriftConjugationReader>(),
    );
  });

  test('composes Quiz candidate source from the Catalog-owned Drift graph', () {
    final container = ProviderContainer();
    addTearDown(container.dispose);

    expect(
      container.read(quizCandidateSourceProvider),
      isA<DriftQuizCandidateSource>(),
    );
  });

  test('resolves Search repository through the Catalog integration adapter',
      () {
    final container = ProviderContainer();
    addTearDown(container.dispose);

    expect(
      container.read(searchQueryRepositoryProvider),
      isA<DriftSearchQueryRepository>(),
    );
  });

  test('allows Search repository to be replaced at the composition boundary',
      () {
    final repository = _SearchQueryRepository();
    final container = ProviderContainer(
      overrides: [searchQueryRepositoryProvider.overrideWithValue(repository)],
    );
    addTearDown(container.dispose);

    expect(container.read(searchQueryRepositoryProvider), same(repository));
  });

  test('allows Quiz candidate source to be replaced with a fake', () {
    final source = _QuizCandidateSource();
    final container = ProviderContainer(
      overrides: [quizCandidateSourceProvider.overrideWithValue(source)],
    );
    addTearDown(container.dispose);

    expect(container.read(quizCandidateSourceProvider), same(source));
  });
}

final class _QuizCandidateSource implements QuizCandidateSource {
  @override
  Future<Result<QuizCandidatePage>> search(QuizCandidateQuery query) async =>
      throw UnimplementedError();
}

final class _SearchQueryRepository implements ISearchQueryRepository {
  @override
  Future<Result<SearchResultPage>> search(SearchQuery query) async =>
      throw UnimplementedError();
}
