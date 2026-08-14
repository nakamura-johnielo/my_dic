import 'package:flutter/material.dart';
import 'package:my_dic/core/ui/search_result_card_shell.dart';
import 'package:my_dic/features/search/internal/presentation/ui_model/search_conjugation_labels.dart';
import 'package:my_dic/features/search/port/search.dart';

/// Search-owned adapter that supplies search-specific conjugation content to
/// the neutral result-card shell.
class CardView extends StatelessWidget {
  const CardView({
    super.key,
    required this.wordId,
    required this.word,
    required this.meaning,
    this.status = const SizedBox.shrink(),
    required this.query,
    this.onTap,
    this.goToQuiz,
    this.starCount,
    this.ranking,
    this.quizBtnMargin = 5,
    this.bgColor,
    this.mainRadius = 16,
    this.designRadius = 4,
    this.rankingON = true,
    this.disableColor,
    this.conjugacions,
  });
  final int wordId;
  final VoidCallback? onTap;
  final VoidCallback? goToQuiz;
  final int? starCount;
  final String word;
  final String meaning;
  final int? ranking;
  final double quizBtnMargin;
  final Color? bgColor;
  final double mainRadius;
  final double designRadius;
  final bool rankingON;
  final Color? disableColor;
  final String query;
  final Map<SearchConjugationMatchKey, String>? conjugacions;
  final Widget status;

  @override
  Widget build(BuildContext context) => SearchResultCardShell(
        word: word,
        meaning: meaning,
        status: status,
        onTap: onTap,
        onQuizTap: goToQuiz,
        ranking: ranking,
        showRanking: rankingON,
        query: query,
        supplementary: conjugacions == null
            ? null
            : ConjSections(conjugacions: conjugacions!, query: query),
        quizButtonMargin: quizBtnMargin,
        backgroundColor: bgColor,
        mainRadius: mainRadius,
        designRadius: designRadius,
        disabledColor: disableColor,
      );
}

class ConjSections extends StatelessWidget {
  const ConjSections(
      {super.key, required this.conjugacions, required this.query});
  final Map<SearchConjugationMatchKey, String> conjugacions;
  final String query;
  @override
  Widget build(BuildContext context) {
    final sections = conjugacions.entries
        .where((entry) => entry.value.isNotEmpty)
        .map((entry) => _ConjMiniSection(
            keyValue: entry.key, conjugation: entry.value, query: query))
        .toList()
      ..sort((a, b) =>
          a.conjugation == query ? -1 : (b.conjugation == query ? 1 : 0));
    return ClipRect(
        child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            physics: const NeverScrollableScrollPhysics(),
            child: Row(
                mainAxisSize: MainAxisSize.min,
                spacing: 8,
                children: sections)));
  }
}

class _ConjMiniSection extends StatelessWidget {
  const _ConjMiniSection(
      {required this.keyValue, required this.conjugation, required this.query});
  final SearchConjugationMatchKey keyValue;
  final String conjugation;
  final String query;
  @override
  Widget build(BuildContext context) {
    var title = '${keyValue.moodTense.shortLabel}${keyValue.subject.name}:';
    if (keyValue.moodTense == SearchMoodTense.participlePast ||
        keyValue.moodTense == SearchMoodTense.participlePresent)
      title = '${keyValue.moodTense.shortLabel}:';
    return Row(spacing: 3, children: [
      Text(title, style: const TextStyle(fontSize: 13)),
      _highlight(context)
    ]);
  }

  Widget _highlight(BuildContext context) {
    final start = conjugation.toLowerCase().indexOf(query.toLowerCase());
    if (query.isEmpty || start < 0)
      return Text(conjugation, style: const TextStyle(fontSize: 15));
    final end = start + query.length;
    final exact = conjugation.length == query.length;
    return RichText(
        text: TextSpan(style: const TextStyle(fontSize: 15), children: [
      TextSpan(text: conjugation.substring(0, start)),
      TextSpan(
          text: conjugation.substring(start, end),
          style: TextStyle(
              fontWeight: FontWeight.bold,
              backgroundColor: exact
                  ? Theme.of(context).colorScheme.primary
                  : Theme.of(context).colorScheme.primary.withValues(alpha: .5),
              color: exact ? Theme.of(context).colorScheme.onPrimary : null)),
      TextSpan(text: conjugation.substring(end)),
    ]));
  }
}
