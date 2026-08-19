import 'package:my_dic/features/word_detail/port/model/word_detail_data.dart';
import 'package:my_dic/features/word_detail/port/model/word_detail_issue.dart';

/// 個別に回復可能な問題を含む、成功した詳細読み込みです。
final class WordDetailResult {
  WordDetailResult({
    required this.data,
    Iterable<WordDetailIssue> issues = const [],
  }) : issues = List.unmodifiable(issues);

  final WordDetailData data;
  final List<WordDetailIssue> issues;
}
