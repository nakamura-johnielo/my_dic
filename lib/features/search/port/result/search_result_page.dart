import 'package:my_dic/features/search/port/error/search_issue.dart';
import 'package:my_dic/features/search/port/model/search_direction.dart';
import 'package:my_dic/features/search/port/model/search_result_item.dart';

/// 検索方向と Catalog のページング情報が明示された Search ページです。
final class SearchResultPage {
  SearchResultPage({
    required this.direction,
    required List<SearchResultItem> items,
    required List<SearchConjugationSuggestion> conjugationSuggestions,
    required this.hasNext,
    required List<SearchIssue> issues,
  })  : items = List.unmodifiable(items),
        conjugationSuggestions = List.unmodifiable(conjugationSuggestions),
        issues = List.unmodifiable(issues);

  final SearchDirection direction;
  final List<SearchResultItem> items;
  final List<SearchConjugationSuggestion> conjugationSuggestions;

  /// [items] から推測せず、Catalog の先読み情報を使用します。
  final bool hasNext;

  final List<SearchIssue> issues;
}
