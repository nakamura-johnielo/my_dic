import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:my_dic/app/bootstrap/feature_composition/quiz_composition.dart';
import 'package:my_dic/app/bootstrap/feature_composition/word_status_composition.dart';
import 'package:my_dic/features/quiz/port/presentation_entry.dart';
import 'package:my_dic/features/quiz/port/quiz.dart';
import 'package:my_dic/features/word_status/port/presentation_entry.dart';

/// App-owned adapter that resolves Quiz's completed capability only when the
/// search route is built, then passes the focused port through the entry API.
class QuizSearchPresentationEntry extends ConsumerWidget {
  const QuizSearchPresentationEntry({
    super.key,
    required this.onOpenQuiz,
  });

  final void Function(CatalogWordRef word, String? displayHint) onOpenQuiz;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final ports = ref.watch(quizPortsProvider);
    final wordStatusPorts = ref.watch(wordStatusPortsProvider);
    return QuizSearchFragment(
      reader: ports.candidateReader,
      onOpenQuiz: onOpenQuiz,
      wordStatusRenderer: (word) =>
          DictionaryStatusButtonsEntry(word: word, ports: wordStatusPorts),
    );
  }
}

/// App-owned adapter for a Quiz game route.
class QuizGamePresentationEntry extends ConsumerWidget {
  const QuizGamePresentationEntry({
    super.key,
    required this.input,
    required this.onOpenWordDetail,
  });

  final QuizGamePresentationInput input;
  final ValueChanged<CatalogWordRef> onOpenWordDetail;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final ports = ref.watch(quizPortsProvider);
    final wordStatusPorts = ref.watch(wordStatusPortsProvider);
    return QuizGameFragment(
      input: input,
      reader: ports.gameReader,
      onOpenWordDetail: onOpenWordDetail,
      wordStatusRenderer: (word) =>
          DictionaryStatusButtonsEntry(word: word, ports: wordStatusPorts),
    );
  }
}
