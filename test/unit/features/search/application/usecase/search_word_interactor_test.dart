import 'package:flutter_test/flutter_test.dart';
import 'package:my_dic/core/shared/errors/domain_errors.dart';
import 'package:my_dic/core/shared/utils/result.dart';
import 'package:my_dic/features/search/application/query/i_search_query_repository.dart';
import 'package:my_dic/features/search/application/query/search_direction.dart';
import 'package:my_dic/features/search/application/query/search_query.dart';
import 'package:my_dic/features/search/application/query/search_result_page.dart';
import 'package:my_dic/features/search/application/usecase/search_word/search_word_interactor.dart';

void main() {
  test('forwards a normal search query to the query repository', () async {
    final repository = _SearchQueryRepositoryFake();
    final interactor = SearchWordInteractor(repository);
    final query = SearchQuery(
      text: 'ser',
      direction: SearchDirection.espJpn,
      page: 0,
      size: 20,
      includeConjugationSuggestions: true,
    );

    final result = await interactor.execute(query);

    expect(result.isSuccess, isTrue);
    expect(repository.query, same(query));
  });

  test('rejects a blank normal search query without calling the repository',
      () async {
    final repository = _SearchQueryRepositoryFake();
    final interactor = SearchWordInteractor(repository);

    final result = await interactor.execute(const SearchQuery(
      text: '  ',
      direction: SearchDirection.espJpn,
      page: 0,
      size: 20,
      includeConjugationSuggestions: true,
    ));

    expect(result.errorOrNull, isA<ValidationError>());
    expect(repository.query, isNull);
  });
}

class _SearchQueryRepositoryFake implements ISearchQueryRepository {
  SearchQuery? query;

  @override
  Future<Result<SearchResultPage>> search(SearchQuery value) async {
    query = value;
    return Result.success(SearchResultPage(
      items: const [],
      conjugationSuggestions: const [],
      hasNext: false,
      issues: const [],
    ));
  }
}
