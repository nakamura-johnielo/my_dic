import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:my_dic/core/presentation/components/button/my_icon_button.dart';
import 'package:my_dic/features/word_status/port/presentation_entry.dart';
import 'package:my_dic/features/catalog/port/catalog.dart';
import 'package:my_dic/features/ranking/port/model/ranking_list_item.dart';
import 'package:my_dic/core/shared/utils/logger.dart';

//スマホ用
class RankingCard extends ConsumerWidget {
  //
  const RankingCard({
    super.key,
    required this.ranking,
    this.onTap,
    this.margin = const EdgeInsets.symmetric(vertical: 1, horizontal: 16),
    this.onOpenQuiz,
  });

  final RankingListItem ranking;
  final VoidCallback? onTap;
  final EdgeInsetsGeometry? margin;
  final void Function(CatalogWordRef word, String? displayHint)? onOpenQuiz;

  static const Color hinshiColor = Color.fromARGB(255, 40, 40, 40);
  static const Color wordColor = Colors.black;
  static const Color rankingColor = Colors.black;
  static const Color meaningColor = Colors.black;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    AppLogger.print("rankingcard wordID: ${ranking.rankedWord}");
    return GestureDetector(
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
            //No.
            SizedBox(
              width: 45,
              child: Text(
                ranking.rank.toString(),
                style: TextStyle(
                  fontSize: 15, //color: rankingColor
                ),
                textAlign: TextAlign.left,
              ),
            ),

            Expanded(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  //Word
                  Expanded(
                    //width: 160,
                    child: Text(
                      ranking.rankedWord,
                      style: TextStyle(
                        fontSize: 15, //color: wordColor
                      ),
                      textAlign: TextAlign.left,
                    ),
                  ),
                  SizedBox(width: 5),
                  Expanded(
                    //width: 160,
                    child: Text(
                      ranking.lemma,
                      style: TextStyle(
                        fontSize: 15, //color: wordColor
                      ),
                      textAlign: TextAlign.left,
                    ),
                  ),
                ],
              ),
            ),

            SizedBox(width: 5),
            if (ranking.hasConjugation)
              MyIconButton(
                iconSize: 22,
                defaultIcon: Icons.handshake_rounded,
                hoveredIconColor: const Color.fromARGB(255, 119, 119, 119),
                onTap: () {
                  onOpenQuiz?.call(
                    CatalogWordRef(
                      catalogId: CatalogId.espJpnMain,
                      wordId: ranking.wordId,
                    ),
                    ranking.lemma,
                  );
                },
              ),

            if (ranking.hasConjugation) SizedBox(width: 3),

            DictionaryStatusButtonsEntry(
              word: CatalogWordRef(
                catalogId: CatalogId.espJpnMain,
                wordId: ranking.wordId,
              ),
            ),
          ]),
        ),
      ),
    );
  }
}
