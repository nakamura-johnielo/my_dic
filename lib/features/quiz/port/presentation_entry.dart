/// Quiz 用に制御された公開プレゼンテーションエントリ。
library;

import 'package:flutter/widgets.dart';
import 'package:my_dic/features/quiz/internal/presentation/view/quiz_presentation_fragments.dart'
    as internal;
import 'package:my_dic/features/quiz/port/quiz.dart';

/// 候補検索用の制御された Flutter エントリ。
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

/// 読み込み済みの 1 つの Quiz ゲーム用の制御された Flutter エントリ。
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
