
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:my_dic/core/presentation/components/button/my_icon_button.dart';
import 'package:my_dic/features/esp_jpn_word_status/di/di.dart';
import 'package:my_dic/features/quiz/consts/card_state.dart';
import 'package:my_dic/features/ranking/domain/entity/ranking.dart';
import 'package:my_dic/features/quiz/di/view_model_di.dart';
import 'package:my_dic/features/quiz/presentation/view/quiz_game_fragment.dart';
import 'package:my_dic/router/navigator_service.dart';
import 'package:my_dic/core/shared/utils/logger.dart';

//スマホ用
class RankingCard extends ConsumerWidget {
  //
  const RankingCard({
    super.key,
    required this.ranking,
    this.onTap,
    this.margin = const EdgeInsets.symmetric(vertical: 1, horizontal: 16),
  });

  final Ranking ranking;
  final VoidCallback? onTap;
  final EdgeInsetsGeometry? margin;

  static const Color hinshiColor = Color.fromARGB(255, 40, 40, 40);
  static const Color wordColor = Colors.black;
  static const Color rankingColor = Colors.black;
  static const Color meaningColor = Colors.black;

  static const Map<String, IconData> bookmarkIcon = {
    "true": Icons.bookmark_rounded,
    "false": Icons.bookmark_border_rounded,
    "added": Icons.bookmark_added_rounded
  };
  static const Map<String, IconData> learnedIcon = {
    "true": Icons.check_circle_rounded,
    "false": Icons.check_circle_outline_rounded
  };

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final command =
        ref.read(espJpnWordStatusCommandProvider(ranking.wordId).notifier);
    final wordStatus =
        ref.watch(espJpnWordStatusUiStateProvider(ranking.wordId));

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
            if (ranking.hasConj)
              MyIconButton(
                iconSize: 22,
                defaultIcon: Icons.handshake_rounded,
                hoveredIconColor: const Color.fromARGB(255, 119, 119, 119),
                onTap: () {
                  //TODO Quiz 初期化をquiz内で行う
                  ref.read(quizGameViewModelProvider.notifier).initialize();
                  ref.read(quizCardStateProvider.notifier).state =
                      QuizCardState.question;
                  ref.read(quizWordProvider.notifier).state = ranking.lemma;
                  //TODO gorouter check
                  ref.read(appNavigatorServiceProvider).toFlashCard(
                      QuizGameFragmentInput(
                          wordId: ranking.wordId, word: ranking.lemma));
                },
              ),

            if (ranking.hasConj) SizedBox(width: 3),

            MyIconButton(
              iconSize: 22,
              defaultIcon: wordStatus.isLearned
                  ? learnedIcon["true"] ?? Icons.error
                  : learnedIcon["false"] ?? Icons.error,
              hoveredIcon: wordStatus.isLearned
                  ? learnedIcon["true"] ?? Icons.error
                  : learnedIcon["false"] ?? Icons.error,
              hoveredIconColor: const Color.fromARGB(255, 119, 119, 119),
              onTap: () {
                command.toggleLearned(wordStatus.isLearned);
              },
            ),
            SizedBox(width: 3),
            MyIconButton(
              iconSize: 24,
              defaultIcon: wordStatus.isBookmarked
                  ? bookmarkIcon["true"] ?? Icons.error
                  : bookmarkIcon["false"] ?? Icons.error,
              hoveredIcon: wordStatus.isBookmarked
                  ? bookmarkIcon["true"] ?? Icons.error
                  : bookmarkIcon["false"] ?? Icons.error,
              hoveredIconColor: const Color.fromARGB(255, 119, 119, 119),
              onTap: () {
                command.toggleBookmark(wordStatus.isBookmarked);
              },
            ),
          ]),
        ),
      ),
    );
  }
}
