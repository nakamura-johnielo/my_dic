import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:my_dic/core/shared/consts/ui/ui.dart';
import 'package:my_dic/features/quiz/internal/game/presentation/components/quiz_card.dart';
import 'package:my_dic/features/word_status/port/presentation_entry.dart';
import 'package:my_dic/features/catalog/port/catalog_word_ref.dart';
import 'package:my_dic/features/quiz/internal/game/application/conjugation/quiz_conjugation.dart';
import 'package:my_dic/features/quiz/internal/game/composition/quiz_game_view_model_provider.dart';
import 'package:my_dic/features/quiz/internal/composition/quiz_game_providers.dart';
import 'package:my_dic/features/quiz/internal/game/application/conjugation/catalog_quiz_conjugation_mapper.dart';
import 'package:my_dic/features/quiz/port/model/quiz_game_load_result.dart';
import 'package:my_dic/features/quiz/port/model/quiz_game_query.dart';
import 'package:my_dic/features/quiz/port/presentation_input.dart';
import 'package:my_dic/core/presentation/error/app_error_message.dart';
import 'package:my_dic/core/shared/errors/app_error.dart';

// ConsumerStatefulWidgetに変更
class QuizGameFragment extends ConsumerStatefulWidget {
  const QuizGameFragment({
    super.key,
    required this.input,
    required this.onOpenWordDetail,
  });
  final QuizGamePresentationInput input;
  final ValueChanged<CatalogWordRef> onOpenWordDetail;

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
    final gameAsync = ref.watch(quizGameLoadProvider(QuizGameQuery(
      input.word,
    )));

    void onSwipe(String dir) {
      quizGameNotifier.inicializeQuizCardStatus();
      if (dir == "right") {
        quizGameNotifier.next();
      } else if (dir == "left") {
        quizGameNotifier.back();
      }
    }

    return gameAsync.when(
      data: (result) {
        if (result is QuizGameNotFound || result is QuizGameNoConjugation) {
          return Scaffold(
            appBar: AppBar(
              title: Text('Quiz Game - ${input.displayHint ?? ''}'),
            ),
            body: Center(
              child: Text("No results...."),
            ),
          );
        }

        if (result is QuizGameLoadFailure) {
          return Scaffold(
          appBar: AppBar(title: Text('Quiz Game - ${input.displayHint ?? ''}')),
            body: Center(child: Text(_quizErrorText(result.error))),
          );
        }
        final game = (result as QuizGameReady).game;
        final conjugaciones =
            CatalogQuizConjugationMapper.fromCatalog(game.conjugation);
        return Scaffold(
          appBar: AppBar(
            title: Text('Quiz Game - ${input.displayHint ?? ''}'),
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
                        '${input.displayHint ?? ''} の活用',
                        style: TextStyle(
                            fontSize: 26, fontWeight: FontWeight.bold),
                      ),
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        spacing: 20,
                        children: [
                          TextButton(
                            onPressed: () {
                              widget.onOpenWordDetail(input.word);
                            },
                            child: Text("> 辞書確認"),
                          ),
                          DictionaryStatusButtonsEntry(
                            word: input.word,
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
                          game.englishGuide,
                          game.beConjugation,
                          game.englishConjugation,
                        ),
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
            title: Text('Quiz Game - ${input.displayHint ?? ''}'),
          ),
          body: Center(child: Text(_quizErrorText(error))),
        );
      },
      loading: () {
        return Scaffold(
          appBar: AppBar(
            title: Text('Quiz Game - ${input.displayHint ?? ''}'),
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
