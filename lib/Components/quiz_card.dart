import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:my_dic/Constants/Enums/cardState.dart';
import 'package:my_dic/Constants/Enums/mood_tense.dart';
import 'package:my_dic/Constants/Enums/subject.dart';

final quizCardStateProvider =
    StateProvider<QuizCardState>((ref) => QuizCardState.question);

class QuizCard extends ConsumerWidget {
  final MoodTense moodTense;
  final String conjugacion;
  final Subject subject;
  final Function onSwipe;
  final String englishSub;

  static const Color subjectColor = Color.fromARGB(255, 62, 62, 62);
  static const Color conjColor = Color.fromARGB(255, 3, 159, 52);
  //final IconData icon;
  const QuizCard(
      {super.key,
      required this.englishSub,
      required this.moodTense,
      required this.conjugacion,
      required this.subject,
      required this.onSwipe});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cardState = ref.watch(quizCardStateProvider);

    return GestureDetector(
      onTap: () {
        // Handle card tap if needed
        ref.read(quizCardStateProvider.notifier).state =
            cardState == QuizCardState.question
                ? QuizCardState.answer
                : QuizCardState.question;
      },
      onHorizontalDragEnd: (details) {
        ref.read(quizCardStateProvider.notifier).state = QuizCardState.question;

        if (details.primaryVelocity != null) {
          if (details.primaryVelocity! < 0) {
            // 右スワイプ
            print("swipe right");
            onSwipe('right');
          } else if (details.primaryVelocity! > 0) {
            // 左スワイプ
            print("swipe left");
            onSwipe('left');
          }
        }
      },
      child:

          // (moodTense == MoodTense.participlePast ||
          //         moodTense == MoodTense.participlePresent)
          //     ? ParticipleCard(
          //         moodTense: moodTense, conjugacion: conjugacion, subject: subject)
          //     :

          ConjCard(
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
  final MoodTense moodTense;
  final String conjugacion;
  final Subject subject;
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
    final cardState = ref.watch(quizCardStateProvider);
    return Card(
      //shadowColor: Colors.grey.withOpacity(0.5),
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
            if (moodTense == MoodTense.participlePast ||
                moodTense == MoodTense.participlePresent)
              Text(
                moodTense.jap,
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
                Text(
                  subject.displayEsp,
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                Container(
                  //color: subjectColor,
                  padding:
                      const EdgeInsets.symmetric(vertical: 4.0, horizontal: 9),
                  decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(2),
                      color: isOnAnswer(cardState) ? null : subjectColor,
                      border: Border.all(
                          color: subjectColor,
                          width:
                              2) //isOnAnswer(cardState) ? Border.all(color: subjectColor, width: 2): null,
                      ),
                  child: Text(
                    conjugacion,
                    style: TextStyle(
                      fontSize: 22,
                      color: isOnAnswer(cardState)
                          ? subjectColor
                          : Colors.transparent,
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
  final MoodTense moodTense;
  final String conjugacion;
  final Subject subject;
  const ParticipleCard(
      {super.key,
      required this.moodTense,
      required this.conjugacion,
      required this.subject});

  static const Color subjectColor = Color.fromARGB(255, 62, 62, 62);
  static const Color conjColor = Color.fromARGB(255, 3, 159, 52);
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cardState = ref.watch(quizCardStateProvider);
    return Card(
      //shadowColor: Colors.grey.withOpacity(0.5),
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
              moodTense.jap,
              style: TextStyle(fontSize: 19, fontWeight: FontWeight.bold),
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
                      color: isOnAnswer(cardState) ? null : subjectColor,
                      border: Border.all(
                          color: subjectColor,
                          width:
                              2) //isOnAnswer(cardState) ? Border.all(color: subjectColor, width: 2): null,
                      ),
                  child: Text(
                    conjugacion,
                    style: TextStyle(
                      fontSize: 22,
                      color: isOnAnswer(cardState)
                          ? subjectColor
                          : Colors.transparent,
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

// class ParticipleCard extends StatelessWidget {
//   final MoodTense moodTense;
//   final String conjugacion;
//   final String query;

//   static const Color subjectColor = Color.fromARGB(255, 62, 62, 62);
//   static const Color conjColor = Colors.black;
//   //final IconData icon;
//   const ParticipleCard(
//       {super.key,
//       required this.moodTense,
//       required this.conjugacion,
//       this.query = ""});

//   @override
//   Widget build(BuildContext context) {
//     return Card(
//       elevation: 5,
//       shape: RoundedRectangleBorder(
//         borderRadius: BorderRadius.circular(15),
//       ),
//       child: Padding(
//         padding: const EdgeInsets.fromLTRB(15, 10, 15, 15),
//         child: Row(
//           spacing: 15,
//           mainAxisSize: MainAxisSize.min,
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: <Widget>[
//             Text(
//               moodTense.jap,
//               style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
//             ),
//             Text(
//               conjugacion,
//               style: TextStyle(fontSize: 16, color: conjColor),
//               textAlign: TextAlign.left,
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }
