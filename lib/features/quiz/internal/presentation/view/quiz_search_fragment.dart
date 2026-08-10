import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:my_dic/core/presentation/components/auto_focus_text_field.dart';
import 'package:my_dic/core/presentation/components/infinityscroll.dart';
import 'package:my_dic/core/presentation/error/app_error_message.dart';
import 'package:my_dic/core/presentation/state/query_state.dart';
import 'package:my_dic/features/catalog/port/catalog_word_ref.dart';
import 'package:my_dic/features/quiz/internal/presentation/provider/view_model_di.dart';
import 'package:my_dic/features/quiz/internal/game/presentation/components/quiz_search_result_card.dart';
import 'package:my_dic/features/quiz/internal/presentation/ui_model/quiz_search_model.dart';
import 'package:my_dic/features/quiz/internal/presentation/view_model/quiz_search_view_model.dart';
import 'package:my_dic/features/quiz/port/model/quiz_candidate.dart';

class QuizSearchFragment extends ConsumerStatefulWidget {
  const QuizSearchFragment({super.key, required this.onOpenQuiz});
  final void Function(CatalogWordRef word, String? displayHint) onOpenQuiz;
  @override
  ConsumerState<QuizSearchFragment> createState() => _QuizSearchFragmentState();
}

class _QuizSearchFragmentState extends ConsumerState<QuizSearchFragment> {
  static const _size = 30;
  late final InfinityScrollController _scroll;
  @override
  void initState() { super.initState(); _scroll = InfinityScrollController(); }
  Future<bool> _load(int nextPage) => ref.read(quizSearchViewModelProvider.notifier).loadSearchResults(_size, nextPage);
  void _tap(QuizCandidate candidate) => widget.onOpenQuiz(candidate.word, candidate.headword);
  @override
  Widget build(BuildContext context) {
    final state = ref.watch(quizSearchViewModelProvider);
    final notifier = ref.read(quizSearchViewModelProvider.notifier);
    return Scaffold(appBar: AppBar(title: const Text('Quiz')), body: Column(children: [
      Padding(padding: const EdgeInsets.all(8), child: AutoFocusTextField(
        decoration: const InputDecoration(labelText: 'Search', border: OutlineInputBorder()),
        onChanged: (text) { notifier.updateQuery(text); _scroll.reset(); if (text.trim().isNotEmpty) _load(0); },
      )),
      Expanded(child: _content(state, notifier)),
    ]));
  }
  Widget _content(QuizSearchState screen, QuizSearchViewModel notifier) => switch (screen.results) {
    QueryInitial() => const Center(child: Text('Enter a search term.')),
    QueryLoading(previousData: null) => const Center(child: CircularProgressIndicator()),
    QueryEmpty() => const Center(child: Text('No matching words found.')),
    QueryFailure(previousData: null, error: final error) => _failure(AppErrorMessage.from(error).text, () => notifier.loadSearchResults(_size, 0)),
    QueryData(value: final data) || QueryLoading(previousData: final data?) || QueryFailure(previousData: final data?, error: _) => _list(data),
  };
  Widget _failure(String text, VoidCallback retry) => Center(child: Column(mainAxisSize: MainAxisSize.min, children: [Text(text), TextButton(onPressed: retry, child: const Text('Retry'))]));
  Widget _list(QuizSearchResults data) => InfinityScrollListView(
    padding: const EdgeInsets.symmetric(horizontal: 10), initialPage: 1, initialHasMore: data.hasNext,
    controller: _scroll, itemCount: data.items.length,
    itemBuilder: (context, index) { final candidate = data.items[index]; return Padding(
      padding: const EdgeInsets.only(bottom: 11), child: QuizSearchResultCard(
        status: const SizedBox.shrink(), onQuizTap: () => _tap(candidate), ranking: candidate.rankingNo,
        word: candidate.headword, meaning: candidate.meaningText ?? '', onTap: () => _tap(candidate))); },
    onLoadMore: _load,
  );
}
