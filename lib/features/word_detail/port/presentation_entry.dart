/// 単語詳細機能の唯一の公開表示エントリです。
library;

import 'package:flutter/widgets.dart';
import 'package:my_dic/features/word_detail/internal/presentation/view/word_detail_fragment.dart';
import 'package:my_dic/features/word_detail/port/word_detail.dart';

/// 制御された Flutter エントリです。内部プロバイダーとウィジェットは非公開のままです。
final class WordDetailEntry extends StatelessWidget {
  const WordDetailEntry({
    super.key,
    required this.input,
    required this.reader,
    required this.onOpenQuiz,
    required this.wordStatusRenderer,
  });

  final WordDetailPresentationInput input;
  final WordDetailQueryPort reader;
  final void Function(CatalogWordRef word, String? displayHint) onOpenQuiz;
  final Widget Function(CatalogWordRef word) wordStatusRenderer;

  @override
  Widget build(BuildContext context) => WordDetailFragment(
        input: input,
        reader: reader,
        onOpenQuiz: onOpenQuiz,
        wordStatusRenderer: wordStatusRenderer,
      );
}
