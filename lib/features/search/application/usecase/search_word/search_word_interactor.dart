import 'package:my_dic/core/shared/errors/domain_errors.dart';
import 'package:my_dic/core/shared/utils/result.dart';
import 'package:my_dic/features/search/application/query/i_search_query_repository.dart';
import 'package:my_dic/features/search/application/query/search_query.dart';
import 'package:my_dic/features/search/application/query/search_result_page.dart';
import 'package:my_dic/features/search/application/usecase/search_word/i_search_word_use_case.dart';

class SearchWordInteractor implements ISearchWordUseCase {
  SearchWordInteractor(this._repository);
  final ISearchQueryRepository _repository;

  @override
  Future<Result<SearchResultPage>> execute(SearchQuery query) {
    if (query.text.trim().isEmpty) {
      return Future.value(Result<SearchResultPage>.failure(
        ValidationError(message: 'A search word is required.'),
      ));
    }
    return _repository.search(query);
  }

  @override
  Future<Result<SearchResultPage>> executeQuiz(SearchQuery query) {
    if (query.text.trim().isEmpty) {
      return Future.value(Result<SearchResultPage>.failure(
        ValidationError(message: 'A search word is required.'),
      ));
    }
    return _repository.searchQuiz(query);
  }
}
