/// The sole public presentation entry for the word-detail feature.
library;

import 'package:flutter/widgets.dart';
import 'package:my_dic/features/word_detail/internal/presentation/view/word_detail_fragment.dart';
import 'package:my_dic/features/word_detail/port/word_detail.dart';

/// Controlled Flutter entry; internal providers and widgets remain private.
final class WordDetailEntry extends StatelessWidget {
  const WordDetailEntry({
    super.key,
    required this.input,
    required this.onOpenQuiz,
    required this.wordStatusRenderer,
  });

  final WordDetailPresentationInput input;
  final void Function(CatalogWordRef word, String? displayHint) onOpenQuiz;
  final Widget Function(CatalogWordRef word) wordStatusRenderer;

  @override
  Widget build(BuildContext context) => WordDetailFragment(
        input: input,
        onOpenQuiz: onOpenQuiz,
        wordStatusRenderer: wordStatusRenderer,
      );
}
