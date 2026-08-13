import 'package:my_dic/core/shared/utils/result.dart';
import 'package:my_dic/features/search/port/model/search_query.dart';
import 'package:my_dic/features/search/port/model/search_result_page.dart';

/// Provider-neutral reader for Search's public query contract.
abstract interface class SearchQueryPort {
  Future<Result<SearchResultPage>> search(SearchQuery query);
}
