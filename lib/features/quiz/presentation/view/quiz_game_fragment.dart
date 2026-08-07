import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:my_dic/core/shared/consts/ui/ui.dart';
import 'package:my_dic/features/quiz/presentation/components/quiz_card.dart';
import 'package:my_dic/features/word_status/domain/dictionary_direction.dart';
import 'package:my_dic/app/presentation/word_status_buttons.dart';
import 'package:my_dic/core/shared/enums/conjugacion/mood_tense.dart';
import 'package:my_dic/core/shared/enums/conjugacion/subject.dart';
import 'package:my_dic/core/shared/enums/word/word_type.dart';
import 'package:my_dic/core/domain/entity/verb/conjugacion/tense_conjugacion.dart';
import 'package:my_dic/core/domain/entity/verb/conjugacions.dart';
import 'package:my_dic/features/quiz/di/provider_di.dart';
import 'package:my_dic/features/quiz/di/view_model_di.dart';
import 'package:my_dic/core/shared/utils/logger.dart';
import 'package:my_dic/app/routing/contracts/quiz_game_route.dart';
import 'package:my_dic/app/routing/contracts/word_detail_route.dart';

// ConsumerStatefulWidgetに変更
class QuizGameFragment extends ConsumerWidget {
  const QuizGameFragment({super.key, required this.route});
  final QuizGameRoute route;

  QuizGameRoute get input => route;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final quizGameNotifier = ref.read(quizGameViewModelProvider.notifier);
    final quizGame = ref.watch(quizGameViewModelProvider);

    //　VVVVVVVVVVV活用の英訳の共有部のデータ読み込みVVVVVVVVV
    final conjEnglishAsync = ref.watch(conjEnglishProvider); //No usage
    final beConjAsync = ref.watch(beConjProvider); //No usage
    final englishConjAsync =
        ref.watch(englishConjByWordIdProvider(input.wordId));

    if (conjEnglishAsync.isLoading ||
        beConjAsync.isLoading ||
        englishConjAsync.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }
    if (conjEnglishAsync.hasError ||
        beConjAsync.hasError ||
        englishConjAsync.hasError) {
      return const Center(child: Text('Load error'));
    }

    AppLogger.print("conjEnglishAsync");
    AppLogger.print("beConjAsync");
    final Map<String, String> englishSubMap = conjEnglishAsync.value!;
    final Map<String, Map<String, String>> beConj = beConjAsync.value!;
    final englishConj = englishConjAsync.value!;
    //^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

    //

    final conjugacionesAsync =
        ref.watch(quizConjugacionsProvider(input.wordId));

    void onSwipe(String dir) {
      quizGameNotifier.inicializeQuizCardStatus();
      if (dir == "right") {
        quizGameNotifier.next();
      } else if (dir == "left") {
        quizGameNotifier.back();
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
          body: Padding(
            padding: const EdgeInsets.fromLTRB(
                0, 0, 0, UIConsts.bottomBarCompleteHeight),
            child: Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                spacing: 40,
                children: [
                  Column(
                    mainAxisSize: MainAxisSize.min,
                    spacing: 7,
                    children: [
                      Text(
                        '${input.word} の活用',
                        style: TextStyle(
                            fontSize: 26, fontWeight: FontWeight.bold),
                      ),
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        spacing: 20,
                        children: [
                          TextButton(
                            onPressed: () =>

                                //TODO gorouter check
                                quizGameNotifier.goToWordDetail(WordDetailRoute(
                                    wordId: input.wordId,
                                    wordType: WordType.espJpn,
                                    hasConj: true)),
                            child: Text("> 辞書確認"),
                          ),
                          DictionaryStatusButtons(
                            wordId: input.wordId,
                            direction: DictionaryDirection.espJpn,
                          ),
                        ],
                      ),
                    ],
                  ),
                  Row(spacing: 10, mainAxisSize: MainAxisSize.min, children: [
                    Text(
                      (quizGame.currentIndex + 1).toString(),
                      style:
                          TextStyle(fontSize: 26, fontWeight: FontWeight.bold),
                    ),
                    Text(
                      "/",
                      style:
                          TextStyle(fontSize: 26, fontWeight: FontWeight.bold),
                    ),
                    Text(
                      quizGame.allLength.toString(),
                      style:
                          TextStyle(fontSize: 21, fontWeight: FontWeight.bold),
                    )
                  ]),
                  QuizCard(
                      onSwipe: onSwipe,
                      moodTense: quizGame.currentTense,
                      conjugacion: displayConjugacion(conjugaciones,
                          quizGame.currentSubject, quizGame.currentTense),
                      subject: quizGame.currentSubject,
                      englishSub: quizGameNotifier.quiz1EnglishSub(
                          englishSubMap, beConj, englishConj),
                      onToggle: quizGameNotifier.toggleQuizCardStatus),
                  Row(spacing: 34, mainAxisSize: MainAxisSize.min, children: [
                    IconButton(
                        onPressed: () => onSwipe("left"),
                        icon: Icon(Icons.arrow_left_rounded)),
                    ElevatedButton(
                      onPressed: () {
                        quizGameNotifier.toggleQuizCardStatus();
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

//TODO usecase化
String displayConjugacion(EspConjugacions conjugaciones, Subject currentSubject,
    MoodTense currentTense) {
  TenseConjugacion? conj = conjugaciones.conjugacions[currentTense];
  if (conj == null) {
    return 'N/A';
  }

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
