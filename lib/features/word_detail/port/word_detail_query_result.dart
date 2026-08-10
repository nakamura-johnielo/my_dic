import 'package:my_dic/core/application/query/query_issue.dart';
import 'package:my_dic/features/word_detail/port/word_detail_view_data.dart';

/// A successful word-detail query, possibly with a non-fatal enrichment issue.
class WordDetailQueryResult {
  const WordDetailQueryResult({required this.viewData, this.issue});

  final WordDetailViewData viewData;
  final QueryIssue? issue;
}
