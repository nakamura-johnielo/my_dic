import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:my_dic/features/quiz/internal/consts/card_state.dart';
import 'package:my_dic/features/quiz/port/model/quiz_conjugation.dart';
import 'package:my_dic/features/quiz/internal/presentation/game/quiz_display.dart';
import 'package:my_dic/features/quiz/internal/presentation/game/provider/quiz_game_view_model_provider.dart';
import 'package:my_dic/core/shared/utils/logger.dart';

class QuizCard extends ConsumerWidget {
  final QuizMoodTense moodTense;
  final String conjugacion;
  final QuizSubject subject;
  final Function onSwipe;
  final String englishSub;
  final Function onToggle;

  const QuizCard({
    super.key,
    required this.englishSub,
    required this.moodTense,
    required this.conjugacion,
    required this.subject,
    required this.onSwipe,
    required this.onToggle,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return GestureDetector(
      onTap: () {
        // Handle card tap if needed
        onToggle();
      },
      onHorizontalDragEnd: (details) {
        if (details.primaryVelocity != null) {
          if (details.primaryVelocity! < 0) {
            // 右スワイプ
            AppLogger.print("swipe right");
            onSwipe('right');
          } else if (details.primaryVelocity! > 0) {
            // 左スワイプ
            AppLogger.print("swipe left");
            onSwipe('left');
          }
        }
      },
      child: ConjCard(
        moodTense: moodTense,
        conjugacion: conjugacion,
        subject: subject,
        englishSub: englishSub,
      ),
    );
  }
}

bool isOnAnswer(QuizCardState state) {
  return state == QuizCardState.answer;
}

class ConjCard extends ConsumerWidget {
  final QuizMoodTense moodTense;
  final String conjugacion;
  final QuizSubject subject;
  final String englishSub;
  const ConjCard(
      {super.key,
      required this.moodTense,
      required this.conjugacion,
      required this.subject,
      required this.englishSub});

  static const Color subjectColor = Color.fromARGB(255, 62, 62, 62);
  static const Color conjColor = Color.fromARGB(255, 3, 159, 52);
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cardState = ref.watch(quizGameViewModelProvider).quizCardState;
    return Card(
      elevation: 5,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
      ),
      child: Padding(
        padding:
            const EdgeInsets.all(30), //EdgeInsets.fromLTRB(15, 10, 15, 15),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            if (moodTense == QuizMoodTense.participlePast ||
                moodTense == QuizMoodTense.participlePresent)
              Text(
                moodTense.japaneseLabel,
                style: TextStyle(fontSize: 14),
              )
            else
              Text(
                "(${moodTense.moodName})  ${moodTense.tenseName}",
                style: TextStyle(fontSize: 14),
              ),
            SizedBox(height: 12),
            Text(
              englishSub,
              style: TextStyle(fontSize: 16),
            ),
            SizedBox(height: 21),
            Row(
              spacing: 26,
              mainAxisSize: MainAxisSize.min,
              children: [
                if (moodTense != QuizMoodTense.participlePast &&
                    moodTense != QuizMoodTense.participlePresent)
                  Text(
                    subject.displaySpanish,
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                Container(
                  padding:
                      const EdgeInsets.symmetric(vertical: 4.0, horizontal: 9),
                  decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(2),
                      color: isOnAnswer(cardState)
                          ? null
                          : Theme.of(context).colorScheme.primary,
                      border: Border.all(
                          color: Theme.of(context).colorScheme.primary,
                          width: 2)),
                  child: Text(
                    conjugacion,
                    style: TextStyle(
                      fontSize: 22,
                      color: isOnAnswer(cardState) ? null : Colors.transparent,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class ParticipleCard extends ConsumerWidget {
  final QuizMoodTense moodTense;
  final String conjugacion;
  final QuizSubject subject;
  const ParticipleCard(
      {super.key,
      required this.moodTense,
      required this.conjugacion,
      required this.subject});

  static const Color subjectColor = Color.fromARGB(255, 62, 62, 62);
  static const Color conjColor = Color.fromARGB(255, 3, 159, 52);
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cardState = ref.watch(quizGameViewModelProvider).quizCardState;
    return Card(
      //shadowColor: Colors.grey.withValues(alpha: 0.5),
      elevation: 5,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
      ),
      child: Padding(
        padding:
            const EdgeInsets.all(30), //EdgeInsets.fromLTRB(15, 10, 15, 15),
        child: Column(
          spacing: 20,
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            Text(
              moodTense.japaneseLabel,
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
            ),
            Row(
              spacing: 26,
              mainAxisSize: MainAxisSize.min,
              children: [
                // Text(
                //   subject.displayEsp,
                //   style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                // ),
                Container(
                  //color: subjectColor,
                  padding:
                      const EdgeInsets.symmetric(vertical: 4.0, horizontal: 9),
                  decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(2),
                      color: isOnAnswer(cardState)
                          ? null
                          : Theme.of(context).colorScheme.primary,
                      border: Border.all(
                          color: Theme.of(context).colorScheme.primary,
                          width:
                              2) //isOnAnswer(cardState) ? Border.all(color: subjectColor, width: 2): null,
                      ),
                  child: Text(
                    conjugacion,
                    style: TextStyle(
                      fontSize: 22,
                      color: isOnAnswer(cardState) ? null : Colors.transparent,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
