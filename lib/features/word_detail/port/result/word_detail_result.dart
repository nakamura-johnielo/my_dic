import 'package:my_dic/features/word_detail/port/model/word_detail_data.dart';
import 'package:my_dic/features/word_detail/port/model/word_detail_issue.dart';

/// A successful detail read, including independently recoverable issues.
final class WordDetailResult {
  WordDetailResult({
    required this.data,
    Iterable<WordDetailIssue> issues = const [],
  }) : issues = List.unmodifiable(issues);

  final WordDetailData data;
  final List<WordDetailIssue> issues;
}
