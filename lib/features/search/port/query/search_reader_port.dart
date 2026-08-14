import 'package:my_dic/core/shared/utils/result.dart';
import 'package:my_dic/features/search/port/query/search_query.dart';
import 'package:my_dic/features/search/port/result/search_result_page.dart';

/// Read-only Search application capability.
abstract interface class SearchQueryPort {
  Future<Result<SearchResultPage>> search(SearchQuery query);
}
