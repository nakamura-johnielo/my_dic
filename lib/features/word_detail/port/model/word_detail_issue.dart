import 'package:my_dic/features/word_detail/port/error/word_detail_read_error.dart';

/// 使用可能な主要詳細データとともに保持される、致命的ではない失敗です。
sealed class WordDetailIssue {
  const WordDetailIssue({required this.error});

  final WordDetailReadError error;
}

/// 任意の活用データは読み込めませんでしたが、辞書データは使用できます。
final class WordDetailConjugationIssue extends WordDetailIssue {
  const WordDetailConjugationIssue({required super.error});
}
