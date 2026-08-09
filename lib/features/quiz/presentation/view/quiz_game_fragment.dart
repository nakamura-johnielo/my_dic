import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:my_dic/app/routing/route_name_resolver.dart';
import 'package:my_dic/core/di/router/router.dart';
import 'package:my_dic/core/shared/consts/ui/ui.dart';
import 'package:my_dic/features/quiz/presentation/components/quiz_card.dart';
import 'package:my_dic/app/presentation/word_status_buttons.dart';
import 'package:my_dic/features/catalog/port/catalog_id.dart';
import 'package:my_dic/features/catalog/port/catalog_word_ref.dart';
import 'package:my_dic/features/quiz/application/conjugation/quiz_conjugation.dart';
import 'package:my_dic/features/quiz/di/provider_di.dart';
import 'package:my_dic/features/quiz/di/view_model_di.dart';
import 'package:my_dic/core/shared/utils/logger.dart';
import 'package:my_dic/app/routing/contracts/quiz_game_route.dart';
import 'package:my_dic/app/routing/contracts/word_detail_route.dart';
import 'package:my_dic/core/presentation/error/app_error_message.dart';
import 'package:my_dic/core/shared/errors/app_error.dart';

// ConsumerStatefulWidgetに変更
class QuizGameFragment extends ConsumerStatefulWidget {
  const QuizGameFragment({super.key, required this.route});
  final QuizGameRoute route;

  QuizGameRoute get input => route;

  @override
  ConsumerState<QuizGameFragment> createState() => _QuizGameFragmentState();
}

class _QuizGameFragmentState extends ConsumerState<QuizGameFragment> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        ref.read(quizGameViewModelProvider.notifier).initialize();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final input = widget.input;
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
      final error =
          conjEnglishAsync.error ?? beConjAsync.error ?? englishConjAsync.error;
      return Scaffold(
        appBar: AppBar(title: Text('Quiz Game - ${input.word}')),
        body: Center(child: Text(_quizErrorText(error))),
      );
    }

    AppLogger.print("conjEnglishAsync");
    AppLogger.print("beConjAsync");
    final Map<String, String> englishSubMap =
        conjEnglishAsync.value ?? const {};
    final Map<String, Map<String, String>> beConj =
        beConjAsync.value ?? const {};
    final englishConj = englishConjAsync.value ?? const <String, String>{};
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
                            onPressed: () {
                              final route = WordDetailRoute(
                                word: CatalogWordRef(
                                  catalogId: CatalogId.espJpnMain,
                                  wordId: input.wordId,
                                ),
                              );
                              context.pushNamed(
                                wordDetailRouteNameFor(
                                    ref.read(entryPointProvider)),
                                pathParameters: route.pathParameters,
                                queryParameters: route.queryParameters,
                              );
                            },
                            child: Text("> 辞書確認"),
                          ),
                          DictionaryStatusButtons(
                            word: CatalogWordRef(
                              catalogId: CatalogId.espJpnMain,
                              wordId: input.wordId,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  Row(spacing: 10, mainAxisSize: MainAxisSize.min, children: [
                    Text(
                      quizGame.hasCurrentQuestion
                          ? (quizGame.currentIndex + 1).toString()
                          : '0',
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
                  if (quizGame.hasCurrentQuestion)
                    QuizCard(
                        onSwipe: onSwipe,
                        moodTense: quizGame.currentTense,
                        conjugacion: displayConjugacion(conjugaciones,
                            quizGame.currentSubject, quizGame.currentTense),
                        subject: quizGame.currentSubject,
                        englishSub: quizGameNotifier.quiz1EnglishSub(
                            englishSubMap, beConj, englishConj),
                        onToggle: quizGameNotifier.toggleQuizCardStatus),
                  if (quizGame.hasCurrentQuestion)
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
          body: Center(child: Text(_quizErrorText(error))),
        );
      },
      loading: () {
        return Scaffold(
          appBar: AppBar(
            title: Text('Quiz Game - ${input.word}'),
          ),
          body: const Center(child: CircularProgressIndicator()),
        );
      },
    );
  }
}

String _quizErrorText(Object? error) => error is AppError
    ? AppErrorMessage.from(error).text
    : 'Unable to load the quiz. Please try again.';

//TODO usecase化
String displayConjugacion(
  QuizConjugation conjugaciones,
  QuizSubject currentSubject,
  QuizMoodTense currentTense,
) =>
    conjugaciones.form(currentTense, currentSubject) ?? 'N/A';
