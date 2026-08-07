import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:my_dic/core/presentation/components/button/my_icon_button.dart';
import 'package:my_dic/features/word_status/domain/dictionary_direction.dart';
import 'package:my_dic/app/presentation/word_status_buttons.dart';
import 'package:my_dic/features/quiz/consts/card_state.dart';
import 'package:my_dic/features/ranking/domain/entity/ranking.dart';
import 'package:my_dic/app/presentation/quiz_view_models.dart';
import 'package:my_dic/app/routing/contracts/quiz_game_route.dart';
import 'package:my_dic/app/routing/route_name_resolver.dart';
import 'package:my_dic/core/di/router/router.dart';
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
                  final route = QuizGameRoute(
                      wordId: ranking.wordId, word: ranking.lemma);
                  context.pushNamed(
                    quizGameRouteNameFor(ref.read(entryPointProvider)),
                    pathParameters: route.pathParameters,
                    queryParameters: route.queryParameters,
                  );
                },
              ),

            if (ranking.hasConj) SizedBox(width: 3),

            DictionaryStatusButtons(
              wordId: ranking.wordId,
              direction: DictionaryDirection.espJpn,
            ),
          ]),
        ),
      ),
    );
  }
}
