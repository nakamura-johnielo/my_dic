//input data DS
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:my_dic/Components/quiz_card.dart';
import 'package:my_dic/Components/status_buttons.dart';
import 'package:my_dic/Constants/Enums/cardState.dart';
import 'package:my_dic/Constants/Enums/mood_tense.dart';
import 'package:my_dic/Constants/Enums/subject.dart';
//import 'package:my_dic/Constants/screen_tab.dart';
import 'package:my_dic/Constants/tab.dart';
import 'package:my_dic/_Business_Rule/_Domain/Entities/verb/conjugacion/conjugacions.dart';
import 'package:my_dic/_Business_Rule/_Domain/Entities/verb/conjugacion/tense_conjugacion.dart';
import 'package:my_dic/_Interface_Adapter/Controller/quiz_controller.dart';
import 'package:my_dic/_View/word_page/word_page_fragment.dart';

class QuizGameFragmentInput {
  final int wordId;
  final String word;
  QuizGameFragmentInput({required this.wordId, required this.word});
}

class QuizGameFragment extends ConsumerWidget {
  const QuizGameFragment({super.key, required this.input});
  final QuizGameFragmentInput input;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final quizState = ref.watch(quizStateProvider);
    final quizStateController = ref.read(quizStateProvider.notifier);
    final quizWord = ref.watch(quizWordProvider);
    //final conjugaciones = ref.watch(quizConjugacionsProvider);
    //quizStateController.quiz1Next();
    //QuizController controller = QuizController();
    final conjugacionesAsync =
        ref.watch(quizConjugacionsProvider(input.wordId));

    void onSwipe(String dir) {
      ref.read(quizCardStateProvider.notifier).state = QuizCardState.question;

      if (dir == "right") {
        quizStateController.quiz1Next();
      } else if (dir == "left") {
        quizStateController.quiz1Back();
      }
    }

    return conjugacionesAsync.when(
      data: (conjugaciones) {
        if (conjugaciones == null) {
          return Scaffold(
            appBar: AppBar(
              title: Text('Quiz Game - ${input.word}'),
            ),
            body: Center(
              child: Text("No results...."),
            ),
          );
        }

        return Scaffold(
          appBar: AppBar(
            title: Text('Quiz Game - ${input.word}'),
          ),
          body: Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              spacing: 40,
              children: [
                Column(
                  mainAxisSize: MainAxisSize.min,
                  spacing: 7,
                  children: [
                    Text(
                      '${quizWord} の活用',
                      style:
                          TextStyle(fontSize: 26, fontWeight: FontWeight.bold),
                    ),
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      spacing: 20,
                      children: [
                        TextButton(
                          onPressed: () => context.push(
                              '/${ScreenTab.search}/${ScreenPage.detail}',
                              extra: WordPageFragmentInput(
                                  wordId: input.wordId, isVerb: true)),
                          child: Text("> 辞書確認"),
                        ),
                        StatusButtons(wordId: input.wordId),
                      ],
                    ),
                  ],
                ),
                Row(spacing: 10, mainAxisSize: MainAxisSize.min, children: [
                  Text(
                    //key: ValueKey( 'text${quizState.currentTense}-${quizState.currentSubject}'),
                    (quizState.currentIndex + 1).toString(),
                    style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold),
                  ),
                  Text(
                    "/",
                    style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold),
                  ),
                  Text(
                    quizState.allLength.toString(),
                    style: TextStyle(fontSize: 21, fontWeight: FontWeight.bold),
                  )
                ]),
                QuizCard(
                    //key: ValueKey(  'card${quizState.currentTense}-${quizState.currentSubject}'),
                    onSwipe: onSwipe,
                    moodTense: quizState.currentTense,
                    conjugacion: conjDisplayString(conjugaciones,
                        quizState.currentSubject, quizState.currentTense),
                    subject: quizState.currentSubject),
                Row(spacing: 34, mainAxisSize: MainAxisSize.min, children: [
                  IconButton(
                      onPressed: () => onSwipe("left"),
                      icon: Icon(Icons.arrow_left_rounded)),
                  ElevatedButton(
                    onPressed: () {
                      ref.read(quizCardStateProvider.notifier).state =
                          ref.watch(quizCardStateProvider) ==
                                  QuizCardState.question
                              ? QuizCardState.answer
                              : QuizCardState.question;
                    },
                    child: Text("FLIP!"),
                  ),
                  IconButton(
                      onPressed: () => onSwipe("right"),
                      icon: Icon(Icons.arrow_right_rounded)),
                ])
              ],
            ),
          ),
        );
      },
      error: (Object error, StackTrace stackTrace) {
        return Scaffold(
          appBar: AppBar(
            title: Text('Quiz Game - ${input.word}'),
          ),
          body: Center(
            child: Text("No results...."),
          ),
        );
      },
      loading: () {
        return Scaffold(
          appBar: AppBar(
            title: Text('Quiz Game - ${input.word}'),
          ),
          body: Center(
            child: Text("No results...."),
          ),
        );
      },
    );
  }
}

String conjDisplayString(Conjugacions conjugaciones, Subject currentSubject,
    MoodTense currentTense) {
  TenseConjugacion? conj = conjugaciones.conjugacions[currentTense];
  if (conj == null) {
    return 'N/A';
  }

  //String val = "";
  switch (currentSubject) {
    case Subject.yo:
      return conj.yo;
    case Subject.tu:
      return conj.tu;
    case Subject.el:
      return conj.el;
    case Subject.nosotros:
      return conj.nosotros;
    case Subject.vosotros:
      return conj.vosotros;
    case Subject.ellos:
      return conj.ellos;
  }
}
