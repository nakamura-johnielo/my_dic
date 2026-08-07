import 'package:flutter_test/flutter_test.dart';
import 'package:my_dic/core/shared/utils/result.dart';
import 'package:my_dic/features/search/application/query/i_search_query_repository.dart';
import 'package:my_dic/features/search/application/query/search_direction.dart';
import 'package:my_dic/features/search/application/query/search_query.dart';
import 'package:my_dic/features/search/application/query/search_result_page.dart';
import 'package:my_dic/features/search/application/usecase/search_word/search_word_interactor.dart';

void main() {
  test('Quiz search uses the query-page port without an old DTO', () async {
    final repository = _SearchQueryRepositoryFake();
    final interactor = SearchWordInteractor(repository);
    final query = SearchQuery(
      text: 'ser',
      direction: SearchDirection.espJpn,
      page: 0,
      size: 20,
      includeConjugationSuggestions: false,
    );

    final result = await interactor.executeQuiz(query);

    expect(result.isSuccess, isTrue);
    expect(repository.quizQuery, same(query));
  });
}

class _SearchQueryRepositoryFake implements ISearchQueryRepository {
  SearchQuery? quizQuery;

  @override
  Future<Result<SearchResultPage>> search(SearchQuery query) =>
      throw UnimplementedError();

  @override
  Future<Result<SearchResultPage>> searchQuiz(SearchQuery query) async {
    quizQuery = query;
    return Result.success(SearchResultPage(
      items: const [],
      conjugationSuggestions: const [],
      hasNext: false,
      issues: const [],
    ));
  }
}
