import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:my_dic/app/presentation/search_card.dart';
import 'package:my_dic/app/routing/contracts/quiz_game_route.dart';
import 'package:my_dic/core/domain/entity/verb/conjugacion/conjugacion_search_result_item.dart';
import 'package:my_dic/core/presentation/components/auto_focus_text_field.dart';
import 'package:my_dic/core/presentation/components/infinityscroll.dart';
import 'package:my_dic/core/presentation/error/app_error_message.dart';
import 'package:my_dic/core/presentation/state/query_state.dart';
import 'package:my_dic/core/shared/enums/ui/word_status_type.dart';
import 'package:my_dic/features/quiz/di/view_model_di.dart';
import 'package:my_dic/features/quiz/presentation/ui_model/quiz_search_model.dart';
import 'package:my_dic/features/quiz/presentation/view_model/quiz_search_view_model.dart';

class QuizSearchFragment extends ConsumerStatefulWidget {
  const QuizSearchFragment({super.key});
  @override
  ConsumerState<QuizSearchFragment> createState() => _QuizSearchFragmentState();
}

class _QuizSearchFragmentState extends ConsumerState<QuizSearchFragment> {
  static const _size = 30;
  late final InfinityScrollController _scroll;
  @override
  void initState() {
    super.initState();
    _scroll = InfinityScrollController();
  }

  Future<bool> _load(int nextPage) async {
    final before = ref
            .read(quizSearchViewModelProvider)
            .results
            .dataOrNull
            ?.items
            .length ??
        0;
    await ref
        .read(quizSearchViewModelProvider.notifier)
        .loadSearchResults(_size, nextPage - 1);
    return (ref
                .read(quizSearchViewModelProvider)
                .results
                .dataOrNull
                ?.items
                .length ??
            0) >
        before;
  }

  void _tap(ConjugacionSearchResultItem word) {
    ref.read(quizGameViewModelProvider.notifier).initialize();
    ref
        .read(quizSearchViewModelProvider.notifier)
        .goToQuiz(QuizGameRoute(wordId: word.wordId, word: word.word));
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(quizSearchViewModelProvider);
    final notifier = ref.read(quizSearchViewModelProvider.notifier);
    return Scaffold(
        appBar: AppBar(title: const Text('Quiz')),
        body: Column(children: [
          Padding(
              padding: const EdgeInsets.all(8),
              child: AutoFocusTextField(
                  decoration: const InputDecoration(
                      labelText: 'Search', border: OutlineInputBorder()),
                  onChanged: (text) {
                    notifier.updateQuery(text);
                    _scroll.reset();
                    if (text.trim().isNotEmpty) _load(0);
                  })),
          Expanded(child: _content(state, notifier))
        ]));
  }

  Widget _content(QuizSearchState screen, QuizSearchViewModel notifier) =>
      switch (screen.results) {
        QueryInitial() => const Center(child: Text('Enter a search term.')),
        QueryLoading(previousData: null) =>
          const Center(child: CircularProgressIndicator()),
        QueryEmpty() => const Center(child: Text('No matching words found.')),
        QueryFailure(previousData: null, error: final error) => _failure(
            AppErrorMessage.from(error).text,
            () => notifier.loadSearchResults(_size, -1)),
        QueryData(value: final data) ||
        QueryLoading(previousData: final data?) ||
        QueryFailure(previousData: final data?, error: _) =>
          _list(screen.query, data),
      };
  Widget _failure(String text, VoidCallback retry) => Center(
          child: Column(mainAxisSize: MainAxisSize.min, children: [
        Text(text),
        TextButton(onPressed: retry, child: const Text('Retry'))
      ]));
  Widget _list(String query, QuizSearchResults data) => InfinityScrollListView(
      padding: const EdgeInsets.symmetric(horizontal: 10),
      initialPage: 0,
      controller: _scroll,
      itemCount: data.items.length,
      itemBuilder: (context, index) {
        final word = data.items[index];
        return Padding(
            padding: const EdgeInsets.only(bottom: 11),
            child: CardView(
                wordStatusType: WordStatusType.espJpnWord,
                goToQuiz: () => _tap(word),
                query: query,
                wordId: word.wordId,
                ranking: data.rankingNos[word.wordId],
                rankingON: true,
                word: word.word,
                meaning: data.simpleMeanings[word.wordId] ?? word.simpleMeaning,
                isBookmarked: false,
                isLearned: false,
                onTap: () => _tap(word)));
      },
      onLoadMore: _load);
}
