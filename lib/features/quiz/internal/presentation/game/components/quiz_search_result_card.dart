import 'package:flutter/material.dart';
import 'package:my_dic/core/ui/search_result_card_shell.dart';

/// 共有検索結果カードの外枠に対する Quiz 所有のアダプター。
class QuizSearchResultCard extends StatelessWidget {
  const QuizSearchResultCard({
    super.key,
    required this.word,
    required this.meaning,
    required this.status,
    required this.onTap,
    required this.onQuizTap,
    this.ranking,
  });
  final String word;
  final String meaning;
  final Widget status;
  final VoidCallback onTap;
  final VoidCallback onQuizTap;
  final int? ranking;
  @override
  Widget build(BuildContext context) => SearchResultCardShell(
        word: word,
        meaning: meaning,
        status: status,
        onTap: onTap,
        onQuizTap: onQuizTap,
        ranking: ranking,
      );
}
