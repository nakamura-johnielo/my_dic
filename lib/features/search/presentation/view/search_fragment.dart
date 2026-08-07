import 'dart:math';
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
import 'package:my_dic/core/shared/enums/ui/word_status_type.dart';
import 'package:my_dic/core/shared/enums/word/word_type.dart';
import 'package:my_dic/features/search/di/view_model_di.dart';
import 'package:my_dic/features/search/presentation/components/card/card_view.dart';
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
    final before = _count(ref.read(searchViewModelProvider).results.dataOrNull);
    await ref
        .read(searchViewModelProvider.notifier)
        .loadSearchResults(_size, nextPage - 1);
    return _count(ref.read(searchViewModelProvider).results.dataOrNull) >
        before;
  }

  int _count(SearchResults? data) => data == null
      ? 0
      : data.espJpnWords.length +
          data.jpnEspWords.length +
          data.conjugacions.length;

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
                onPressed: () => notifier.loadSearchResults(_size, -1),
                child: const Text('Retry'))
          ])),
        QueryData(value: final data) ||
        QueryLoading(previousData: final data?) ||
        QueryFailure(previousData: final data?, error: _) =>
          _list(screen.query, data, notifier),
      };
  Widget _list(String query, SearchResults data, SearchViewModel notifier) {
    if (data.jpnEspWords.isNotEmpty) {
      return InfinityScrollListView(
          padding: const EdgeInsets.symmetric(horizontal: 10),
          initialPage: 0,
          controller: _scroll,
          itemCount: data.jpnEspWords.length,
          itemBuilder: (context, index) {
            final word = data.jpnEspWords[index];
            return Padding(
                padding: const EdgeInsets.only(bottom: 11),
                child: CardView(
                    query: query,
                    wordId: word.id,
                    rankingON: false,
                    word: word.word,
                    meaning: data.simpleMeanings[word.id] ?? '----',
                    isBookmarked: false,
                    isLearned: false,
                    wordStatusType: WordStatusType.jpnEspWord,
                    onTap: () => _toWordDetail(WordDetailRoute(
                        wordId: word.id,
                        wordType: WordType.jpnEsp,
                        hasConj: false))));
          },
          onLoadMore: _load);
    }
    final conjunctions = min(_conjCount, data.conjugacions.length);
    return InfinityScrollListView(
        padding: const EdgeInsets.symmetric(horizontal: 10),
        initialPage: 0,
        controller: _scroll,
        itemCount: conjunctions + data.espJpnWords.length,
        itemBuilder: (context, index) {
          if (index < conjunctions) {
            final word = data.conjugacions[index];
            return _espCard(query, word.wordId, word.word, word.matches, data,
                notifier, true);
          }
          final word = data.espJpnWords[index - conjunctions];
          return _espCard(query, word.wordId, word.word, null, data, notifier,
              word.hasVerb());
        },
        onLoadMore: _load);
  }

  Widget _espCard(String query, int id, String word, dynamic matches,
          SearchResults data, SearchViewModel notifier, bool hasConj) =>
      Padding(
          padding: const EdgeInsets.only(bottom: 11),
          child: CardView(
              wordStatusType: WordStatusType.espJpnWord,
              goToQuiz: () => _toQuiz(QuizGameRoute(wordId: id, word: word)),
              query: query,
              wordId: id,
              ranking: data.rankingNos[id],
              rankingON: true,
              word: word,
              conjugacions: matches,
              starCount: data.starCounts[id],
              meaning: data.simpleMeanings[id] ?? '',
              isBookmarked: false,
              isLearned: false,
              onTap: () => _toWordDetail(WordDetailRoute(
                  wordId: id, wordType: WordType.espJpn, hasConj: hasConj))));
}
