import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:my_dic/app/bootstrap/catalog_composition.dart';
import 'package:my_dic/app/integration/catalog_quiz/catalog_quiz_providers.dart';
import 'package:my_dic/app/integration/catalog_search/catalog_search_providers.dart';
import 'package:my_dic/core/shared/utils/result.dart';
import 'package:my_dic/features/catalog/internal/infrastructure/drift/drift_catalog_reader.dart';
import 'package:my_dic/features/catalog/internal/infrastructure/drift/drift_conjugation_reader.dart';
import 'package:my_dic/features/quiz/port/candidate_source.dart';
import 'package:my_dic/features/quiz/port/model/quiz_candidate_page.dart';
import 'package:my_dic/features/quiz/port/model/quiz_candidate_query.dart';
import 'package:my_dic/features/search/port/model/search_query.dart';
import 'package:my_dic/features/search/port/model/search_result_page.dart';
import 'package:my_dic/features/search/port/reader.dart';

void main() {
  test('resolves Catalog readers through the public Catalog composition', () {
    final container = ProviderContainer();
    addTearDown(container.dispose);

    expect(container.read(catalogReaderPortProvider), isA<DriftCatalogReaderPort>());
    expect(
      container.read(conjugationReaderPortProvider),
      isA<DriftConjugationReaderPort>(),
    );
  });

  test('composes Quiz candidate source from the Catalog-owned Drift graph', () {
    final container = ProviderContainer();
    addTearDown(container.dispose);

    expect(
      container.read(quizCandidateSourceProvider),
      isA<QuizCandidateSource>(),
    );
  });

  test('resolves Search reader through the Catalog integration adapter', () {
    final container = ProviderContainer();
    addTearDown(container.dispose);

    expect(
      container.read(searchReaderPortProvider),
      isA<SearchReaderPort>(),
    );
  });

  test('allows Search reader to be replaced at the composition boundary', () {
    final repository = _SearchReaderPort();
    final container = ProviderContainer(
      overrides: [searchReaderPortProvider.overrideWithValue(repository)],
    );
    addTearDown(container.dispose);

    expect(container.read(searchReaderPortProvider), same(repository));
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

final class _SearchReaderPort implements SearchReaderPort {
  @override
  Future<Result<SearchResultPage>> search(SearchQuery query) async =>
      throw UnimplementedError();
}
