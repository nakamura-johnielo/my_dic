import 'package:my_dic/core/shared/utils/result.dart';
import 'package:my_dic/features/search/port/query/search_query.dart';
import 'package:my_dic/features/search/port/result/search_result_page.dart';

/// 読み取り専用の Search アプリケーション機能です。
abstract interface class SearchQueryPort {
  Future<Result<SearchResultPage>> search(SearchQuery query);
}
