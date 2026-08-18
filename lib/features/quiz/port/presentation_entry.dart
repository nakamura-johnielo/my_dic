/// The controlled public presentation entries for Quiz.
library;

import 'package:flutter/widgets.dart';
import 'package:my_dic/features/quiz/internal/presentation/view/quiz_presentation_fragments.dart'
    as internal;
import 'package:my_dic/features/quiz/port/quiz.dart';

/// Controlled Flutter entry for candidate search.
class QuizSearchFragment extends StatelessWidget {
  const QuizSearchFragment({
    super.key,
    required this.reader,
    required this.onOpenQuiz,
    required this.wordStatusRenderer,
  });

  final QuizCandidateQueryPort reader;
  final void Function(CatalogWordRef word, String? displayHint) onOpenQuiz;
  final Widget Function(CatalogWordRef word) wordStatusRenderer;

  @override
  Widget build(BuildContext context) => internal.QuizSearchFragment(
        reader: reader,
        onOpenQuiz: onOpenQuiz,
        wordStatusRenderer: wordStatusRenderer,
      );
}

/// Controlled Flutter entry for one loaded Quiz game.
class QuizGameFragment extends StatelessWidget {
  const QuizGameFragment({
    super.key,
    required this.input,
    required this.reader,
    required this.onOpenWordDetail,
    required this.wordStatusRenderer,
  });

  final QuizGamePresentationInput input;
  final QuizGameQueryPort reader;
  final ValueChanged<CatalogWordRef> onOpenWordDetail;
  final Widget Function(CatalogWordRef word) wordStatusRenderer;

  @override
  Widget build(BuildContext context) => internal.QuizGameFragment(
        input: input,
        reader: reader,
        onOpenWordDetail: onOpenWordDetail,
        wordStatusRenderer: wordStatusRenderer,
      );
}
