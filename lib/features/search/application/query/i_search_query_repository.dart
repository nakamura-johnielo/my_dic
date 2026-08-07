import 'package:my_dic/core/shared/utils/result.dart';
import 'package:my_dic/features/search/application/query/search_query.dart';
import 'package:my_dic/features/search/application/query/search_result_page.dart';

/// Query port for Search screen projections.
abstract interface class ISearchQueryRepository {
  Future<Result<SearchResultPage>> search(SearchQuery query);

  /// Quiz's paged conjugation lookup using the same query page contract.
  Future<Result<SearchResultPage>> searchQuiz(SearchQuery query);
}
