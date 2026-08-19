import 'package:flutter/material.dart';
import 'package:my_dic/features/search/internal/presentation/components/card/card_view.dart';
import 'package:my_dic/features/search/port/search.dart';

/// 共通の結果カードシェル用の Search 表示アダプターです。
class SearchResultCard extends StatelessWidget {
  const SearchResultCard({
    super.key,
    required this.wordId,
    required this.word,
    required this.meaning,
    required this.query,
    required this.status,
    this.onTap,
    this.onQuizTap,
    this.ranking,
    this.showRanking = true,
    this.conjugations,
  });
  final int wordId;
  final String word;
  final String meaning;
  final String query;
  final Widget status;
  final VoidCallback? onTap;
  final VoidCallback? onQuizTap;
  final int? ranking;
  final bool showRanking;
  final Map<SearchConjugationMatchKey, String>? conjugations;
  @override
  Widget build(BuildContext context) => CardView(
        wordId: wordId,
        word: word,
        meaning: meaning,
        query: query,
        status: status,
        onTap: onTap,
        goToQuiz: onQuizTap,
        ranking: ranking,
        rankingON: showRanking,
        conjugacions: conjugations,
      );
}
