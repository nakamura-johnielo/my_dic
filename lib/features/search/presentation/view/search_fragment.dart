import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:my_dic/app/routing/route_name_resolver.dart';
import 'package:my_dic/core/di/router/router.dart';
import 'package:my_dic/app/routing/contracts/quiz_game_route.dart';
import 'package:my_dic/app/routing/contracts/word_detail_route.dart';
import 'package:my_dic/core/presentation/components/auto_focus_text_field.dart';
import 'package:my_dic/core/presentation/components/infinityscroll.dart';
import 'package:my_dic/core/presentation/error/app_error_message.dart';
import 'package:my_dic/core/presentation/state/query_state.dart';
import 'package:my_dic/features/search/di/view_model_di.dart';
import 'package:my_dic/features/search/presentation/components/card/card_view.dart';
import 'package:my_dic/features/search/application/query/conjugation_search_item.dart';
import 'package:my_dic/features/search/application/query/search_direction.dart';
import 'package:my_dic/features/search/application/query/search_result_item.dart';
import 'package:my_dic/features/search/presentation/ui_model/search_ui_model.dart';
import 'package:my_dic/features/search/presentation/view_model/viewmodel.dart';

class SearchFragment extends ConsumerStatefulWidget {
  const SearchFragment({super.key});
  @override
  ConsumerState<SearchFragment> createState() => _SearchFragmentState();
}

class _SearchFragmentState extends ConsumerState<SearchFragment> {
  static const _size = 30;
  static const _conjCount = 2;
  late final InfinityScrollController _scroll;
  @override
  void initState() {
    super.initState();
    _scroll = InfinityScrollController();
  }

  Future<bool> _load(int nextPage) async {
    return ref
        .read(searchViewModelProvider.notifier)
        .loadSearchResults(_size, nextPage);
  }

  void _toWordDetail(WordDetailRoute route) => context.pushNamed(
        wordDetailRouteNameFor(ref.read(entryPointProvider)),
        pathParameters: route.pathParameters,
        queryParameters: route.queryParameters,
      );

  void _toQuiz(QuizGameRoute route) => context.pushNamed(
        quizGameRouteNameFor(ref.read(entryPointProvider)),
        pathParameters: route.pathParameters,
        queryParameters: route.queryParameters,
      );
  @override
  Widget build(BuildContext context) {
    final screen = ref.watch(searchViewModelProvider);
    final notifier = ref.read(searchViewModelProvider.notifier);
    return Scaffold(
        appBar: AppBar(title: const Text('search')),
        body: Column(children: [
          Padding(
              padding: const EdgeInsets.all(8),
              child: AutoFocusTextField(
                  decoration: const InputDecoration(
                      labelText: 'Search', border: OutlineInputBorder()),
                  onChanged: (text) {
                    notifier.updateQuery(text);
                    _scroll.reset();
                    if (text.trim().isNotEmpty) {
                      _load(0);
                    }
                  })),
          Expanded(child: _content(screen, notifier))
        ]));
  }

  Widget _content(SearchState screen, SearchViewModel notifier) =>
      switch (screen.results) {
        QueryInitial() => const Center(child: Text('Enter a search term.')),
        QueryLoading(previousData: null) =>
          const Center(child: CircularProgressIndicator()),
        QueryEmpty() => const Center(child: Text('No matching words found.')),
        QueryFailure(previousData: null, error: final error) => Center(
              child: Column(mainAxisSize: MainAxisSize.min, children: [
            Text(AppErrorMessage.from(error).text),
            TextButton(
                onPressed: () => notifier.loadSearchResults(_size, 0),
                child: const Text('Retry'))
          ])),
        QueryData(value: final data) ||
        QueryLoading(previousData: final data?) ||
        QueryFailure(previousData: final data?, error: _) =>
          _list(screen.query, data, notifier),
      };
  Widget _list(String query, SearchResults data, SearchViewModel notifier) {
    if (data.direction == SearchDirection.jpnEsp) {
      return InfinityScrollListView(
          padding: const EdgeInsets.symmetric(horizontal: 10),
          // The first page is loaded explicitly when the query changes.
          initialPage: 1,
          initialHasMore: data.hasNext,
          controller: _scroll,
          itemCount: data.items.length,
          itemBuilder: (context, index) {
            final word = data.items[index];
            return Padding(
                padding: const EdgeInsets.only(bottom: 11),
                child: CardView(
                    query: query,
                    wordId: word.wordId,
                    rankingON: false,
                    word: word.headword,
                    meaning: word.meaningText ?? '',
                    statusWord: word.word,
                    onTap: () =>
                        _toWordDetail(WordDetailRoute(word: word.word))));
          },
          onLoadMore: _load);
    }
    final conjunctions =
        data.conjugationSuggestions.take(_conjCount).toList(growable: false);
    return InfinityScrollListView(
        padding: const EdgeInsets.symmetric(horizontal: 10),
        // The first page is loaded explicitly when the query changes.
        initialPage: 1,
        initialHasMore: data.hasNext,
        controller: _scroll,
        itemCount: conjunctions.length + data.items.length,
        itemBuilder: (context, index) {
          if (index < conjunctions.length) {
            return _conjugationCard(query, conjunctions[index]);
          }
          return _espCard(query, data.items[index - conjunctions.length]);
        },
        onLoadMore: _load);
  }

  Widget _espCard(String query, SearchResultItem item) => Padding(
      padding: const EdgeInsets.only(bottom: 11),
      child: CardView(
          statusWord: item.word,
          goToQuiz: item.hasConjugation
              ? () => _toQuiz(
                  QuizGameRoute(wordId: item.wordId, word: item.headword))
              : null,
          query: query,
          wordId: item.wordId,
          ranking: item.rankingNo,
          rankingON: true,
          word: item.headword,
          starCount: item.starCount,
          meaning: item.meaningText ?? '',
          onTap: () => _toWordDetail(WordDetailRoute(word: item.word))));

  Widget _conjugationCard(String query, ConjugationSearchItem item) => Padding(
        padding: const EdgeInsets.only(bottom: 11),
        child: CardView(
          statusWord: item.word,
          goToQuiz: () =>
              _toQuiz(QuizGameRoute(wordId: item.wordId, word: item.headword)),
          query: query,
          wordId: item.wordId,
          ranking: item.rankingNo,
          rankingON: true,
          word: item.headword,
          conjugacions: item.matches,
          starCount: item.starCount,
          meaning: item.meaningText ?? '',
          onTap: () => _toWordDetail(WordDetailRoute(
            word: item.word,
          )),
        ),
      );
}
