import 'package:flutter/material.dart';
import 'package:my_dic/core/presentation/components/button/my_icon_button.dart';
import 'package:my_dic/features/ranking/port/ranking.dart';

class RankingCard extends StatelessWidget {
  const RankingCard({
    super.key,
    required this.ranking,
    required this.wordStatusRenderer,
    this.onTap,
    this.margin = const EdgeInsets.symmetric(vertical: 1, horizontal: 16),
    this.onOpenQuiz,
  });

  final RankingItem ranking;
  final Widget Function(CatalogWordRef word) wordStatusRenderer;
  final VoidCallback? onTap;
  final EdgeInsetsGeometry? margin;
  final void Function(CatalogWordRef word, String? displayHint)? onOpenQuiz;

  @override
  Widget build(BuildContext context) => GestureDetector(
        onTap: onTap,
        child: Card(
          margin: margin,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(6),
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 11, horizontal: 11),
            child: Row(children: [
              SizedBox(
                width: 45,
                child: Text(
                  ranking.rank.toString(),
                  style: const TextStyle(fontSize: 15),
                  textAlign: TextAlign.left,
                ),
              ),
              Expanded(
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Text(
                        ranking.rankedWord,
                        style: const TextStyle(fontSize: 15),
                        textAlign: TextAlign.left,
                      ),
                    ),
                    const SizedBox(width: 5),
                    Expanded(
                      child: Text(
                        ranking.lemma,
                        style: const TextStyle(fontSize: 15),
                        textAlign: TextAlign.left,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 5),
              if (ranking.hasConjugation)
                MyIconButton(
                  iconSize: 22,
                  defaultIcon: Icons.handshake_rounded,
                  hoveredIconColor: const Color.fromARGB(255, 119, 119, 119),
                  onTap: () => onOpenQuiz?.call(ranking.word, ranking.lemma),
                ),
              if (ranking.hasConjugation) const SizedBox(width: 3),
              wordStatusRenderer(ranking.word),
            ]),
          ),
        ),
      );
}
