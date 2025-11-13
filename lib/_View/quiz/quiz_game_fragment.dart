import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:my_dic/Components/quiz_card.dart';
import 'package:my_dic/Components/status_buttons.dart';
import 'package:my_dic/Constants/Enums/cardState.dart';
import 'package:my_dic/Constants/Enums/mood_tense.dart';
import 'package:my_dic/Constants/Enums/subject.dart';
import 'package:my_dic/Constants/tab.dart';
import 'package:my_dic/DI/product.dart';
import 'package:my_dic/_Business_Rule/_Domain/Entities/verb/conjugacion/conjugacions.dart';
import 'package:my_dic/_Business_Rule/_Domain/Entities/verb/conjugacion/tense_conjugacion.dart';
import 'package:my_dic/_Interface_Adapter/Controller/quiz_controller.dart';
import 'package:my_dic/_View/word_page/word_page_fragment.dart';
import 'package:my_dic/utils/json.dart';

class QuizGameFragmentInput {
  final int wordId;
  final String word;
  QuizGameFragmentInput({required this.wordId, required this.word});
}

final conjEnglishProvider = FutureProvider<Map<String, String>>((ref) async {
  return await getConjEnglish();
});

final beConjProvider =
    FutureProvider<Map<String, Map<String, String>>>((ref) async {
  return await getBeConj();
});

// 追加: DBから英語活用を取得（wordIdごと）
final englishConjByWordIdProvider =
    FutureProvider.family<Map<String, String>, int>((ref, wordId) async {
  final controller = DI<QuizController>();
  return controller.fetchEnglishConj(wordId);
});

// ConsumerStatefulWidgetに変更
class QuizGameFragment extends ConsumerWidget {
  const QuizGameFragment({super.key, required this.input});
  final QuizGameFragmentInput input;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final controller = DI<QuizController>();
    //controller.fetchEnglishConj(input.wordId);
    //活用の英訳の共有部のデータ読み込み
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

    print("conjEnglishAsync");
    print("beConjAsync");
    final Map<String, String> englishSubMap = conjEnglishAsync.value!;
    final Map<String, Map<String, String>> beConj = beConjAsync.value!;
    final englishConj = englishConjAsync.value!;
    //
    final quizState = ref.watch(quizStateProvider);
    final quizStateController = ref.read(quizStateProvider.notifier);
    final quizWord = ref.watch(quizWordProvider);
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
                  onSwipe: onSwipe,
                  moodTense: quizState.currentTense,
                  conjugacion: conjDisplayString(conjugaciones,
                      quizState.currentSubject, quizState.currentTense),
                  subject: quizState.currentSubject,
                  englishSub: controller.quiz1EnglishSub(
                      englishSubMap,
                      beConj,
                      englishConj,
                      quizState.currentTense,
                      quizState.currentSubject),
                ),
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

Future<Map<String, String>> getConjEnglish() async {
  print("==============-map");
  const path = 'assets/data/es_conjugacion_en_translation.json';
  final map = await readJsonFile(path); //as Map<String, String>;
  // final s = map.map((k, v) => MapEntry(k, v.toString()));
  // print(s.keys.take(5));
  //print(map.keys);
  //return map; //.map((k, v) => MapEntry(k, v.toString()));
  return map.map((k, v) => MapEntry(k, v.toString()));
}

Future<Map<String, Map<String, String>>> getBeConj() async {
  const path = 'assets/data/be_conjugacion.json';
  final map = await readJsonFile(path);

  return map.map((k, v) {
    final innerMap =
        (v as Map<String, dynamic>).map((s, t) => MapEntry(s, t.toString()));
    return MapEntry(k, innerMap);
  });
}
