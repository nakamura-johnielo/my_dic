import 'package:my_dic/core/shared/utils/result.dart';
import 'package:my_dic/features/search/port/model/search_query.dart';
import 'package:my_dic/features/search/port/model/search_result_page.dart';

abstract class ISearchWordUseCase {
  Future<Result<SearchResultPage>> execute(SearchQuery query);
}
