import 'dart:math';

import 'package:my_dic/core/shared/enums/ui/word_status_type.dart';
import 'package:my_dic/core/shared/utils/logger.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:my_dic/core/presentation/components/auto_focus_text_field.dart';
import 'package:my_dic/features/quiz/presentation/view/quiz_game_fragment.dart';
import 'package:my_dic/features/search/presentation/components/card/card_view.dart';
import 'package:my_dic/core/shared/enums/word/word_type.dart';
import 'package:my_dic/core/presentation/components/infinityscroll.dart';
import 'package:my_dic/features/search/di/view_model_di.dart';
import 'package:my_dic/features/word_page/presentation/view/word_page_fragment.dart';

class SearchFragment extends ConsumerStatefulWidget {
  const SearchFragment({super.key});

  @override
  ConsumerState<SearchFragment> createState() => _SearchFragmentState();
}

class _SearchFragmentState extends ConsumerState<SearchFragment> {
  int _currentPage = -1;
  final int _size = 30; //searchの1ページの取得件数
  int _previousConjItemLength = 0;
  int _previousEspJpnItemLength = 0;
  int _previousJpnEspItemLength = 0;
  late final InfinityScrollController _infinityScrollController;
  final int initialPage = 0;

  final int conjDisplayCount = 2;

  @override
  void initState() {
    super.initState();
    _infinityScrollController = InfinityScrollController();
  }

  Future<bool> _loadNextPage(int nextPage) async {
    AppLogger.print("_loadNextPage: $nextPage");

    final viewModel = ref.read(searchViewModelProvider.notifier);

    _setCurrentItemLength();
    await viewModel.loadSearchResults(
      _size,
      nextPage - 1,
    );
    final canFetch = _canFetch();
    AppLogger.print("canfetch:$canFetch");
    return canFetch;
  }

  void _resetPage() {
    _infinityScrollController.reset();
    setState(() {
      _previousEspJpnItemLength = 0;
      _previousConjItemLength = 0;
      _previousJpnEspItemLength = 0;
      _currentPage = -1;
    });
  }

  void _setCurrentItemLength() {
    final viewModel = ref.read(searchViewModelProvider);
    _previousEspJpnItemLength = viewModel.espJpnWords.length;
    _previousConjItemLength = viewModel.conjugacions.length;
    _previousJpnEspItemLength = viewModel.jpnEspWords.length;
  }

  bool _canFetch() {
    final viewModel = ref.read(searchViewModelProvider);
    final currentEspJpnItemLength = viewModel.espJpnWords.length;
    final currentConjItemLength = viewModel.conjugacions.length;
    final currentJpnEspItemLength = viewModel.jpnEspWords.length;
    AppLogger.print(
        "EspJpn current:$currentEspJpnItemLength, pre:$_previousEspJpnItemLength");
    return currentEspJpnItemLength > _previousEspJpnItemLength ||
        currentConjItemLength > _previousConjItemLength ||
        currentJpnEspItemLength > _previousJpnEspItemLength;
  }

  @override
  Widget build(BuildContext context) {
    final viewModel = ref.watch(searchViewModelProvider);
    final viewModelNotifier = ref.read(searchViewModelProvider.notifier);
    AppLogger.print("0 Fragment in build");

    return Scaffold(
      appBar: AppBar(
        title: Text('search'),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: AutoFocusTextField(
              decoration: InputDecoration(
                labelText: 'Search',
                border: OutlineInputBorder(),
              ),
              onChanged: (value) {
                viewModelNotifier.updateQuery(value);
                viewModelNotifier.clearResults();
                _resetPage();
              },
            ),
          ),
          Expanded(
              child: viewModel.jpnEspWords.isNotEmpty
                  //========JPN ESP====================================
                  ? InfinityScrollListView(
                      padding: EdgeInsetsGeometry.symmetric(horizontal: 10),
                      autoLoadFirstPage: true,
                      initialPage: initialPage,
                      controller: _infinityScrollController,
                      itemCount: viewModel.jpnEspWords.length,
                      itemBuilder: (context, index) {
                        final jpnEspWord = viewModel.jpnEspWords[index];
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 11),
                          child: CardView(
                            query: viewModel.query,
                            wordId: jpnEspWord.id,
                            rankingON: false,
                            word: jpnEspWord.word,
                            meaning: viewModel.simpleMeanings[jpnEspWord.id] ?? '----',
                            isBookmarked: false,
                            isLearned: false,
                            onTap: () {
                              //TODO gorouter check
                              viewModelNotifier.goToWordDetail(WordPageInput(
                                  wordId: jpnEspWord.id,
                                  wordType: WordType.jpnEsp,
                                  hasConj: false));
                            }, wordStatusType: WordStatusType.jpnEspWord,
                          ),
                        );
                      },
                      onLoadMore: _loadNextPage,
                    )
                  //===========ESP JPN================================
                  : InfinityScrollListView(
                      padding: EdgeInsetsGeometry.symmetric(horizontal: 10),
                      autoLoadFirstPage: true,
                      initialPage: initialPage,
                      controller: _infinityScrollController,
                      itemCount: ( //viewModel.conjugacions.length +
                          min(conjDisplayCount, viewModel.conjugacions.length) +
                              viewModel.espJpnWords.length),
                      itemBuilder: (context, index) {
                        final query = viewModel.query;
                        //表示個数と実際に持っいる個数を比較
                        final conjLength = min(
                            conjDisplayCount, viewModel.conjugacions.length);

                        //先にconj
                        if (index < conjLength ) {
                          final conjugacion = viewModel.conjugacions[index];
                          final meaning = viewModel.simpleMeanings[conjugacion.wordId] ?? '';
                          final ranking = viewModel.rankingNos[conjugacion.wordId];
                          final starCount = viewModel.starCounts[conjugacion.wordId];
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 11),
                            child: CardView(wordStatusType: WordStatusType.espJpnWord,
                              goToQuiz: () => viewModelNotifier.goToQuiz(
                                  QuizGameFragmentInput(
                                      wordId: conjugacion.wordId,
                                      word: conjugacion.word)),
                              wordId: conjugacion.wordId,
                              word: conjugacion.word,
                              query: query,
                              conjugacions: conjugacion.matches,
                              rankingON: true,
                              ranking: ranking,
                              starCount: starCount,
                              meaning: meaning,
                              isBookmarked: false,
                              isLearned: false,
                              onTap: () {
                                //TODO gorouter check

                                viewModelNotifier.goToWordDetail(WordPageInput(
                                    wordId: conjugacion.wordId,
                                    wordType: WordType.espJpn,
                                    hasConj: true));
                              },
                            ),
                          );
                        }
                        index = index - conjLength; //conjLength;
                        final espJpnWord = viewModel.espJpnWords[index];
                        final meaning = viewModel.simpleMeanings[espJpnWord.wordId] ?? '';
                        final ranking = viewModel.rankingNos[espJpnWord.wordId];
                        final starCount = viewModel.starCounts[espJpnWord.wordId];

                        return Padding(
                          padding: const EdgeInsets.only(bottom: 11),
                          child: CardView(wordStatusType: WordStatusType.espJpnWord,
                            goToQuiz: () => viewModelNotifier.goToQuiz(
                                QuizGameFragmentInput(
                                    wordId: espJpnWord.wordId,
                                    word: espJpnWord.word)),
                            query: query,
                            wordId: espJpnWord.wordId, //jpnEspWord.id,
                            ranking: ranking,
                            rankingON: true,
                            // conjugations: index % 3 == 0
                            //     ? "現在-yo: soy  現在-yo: soy  現在-yo: soy  現在-yo: soy  現在-yo: soy"
                            //     : null,
                            word: espJpnWord.word,
                            starCount: starCount,
                            meaning: meaning,
                            isBookmarked: false,
                            isLearned: false,
                            onTap: () {
                              //TODO gorouter check
                              viewModelNotifier.goToWordDetail(WordPageInput(
                                  wordId: espJpnWord.wordId,
                                  wordType: WordType.espJpn,
                                  hasConj: espJpnWord.hasVerb()));
                            },
                          ),
                        );
                      },
                      onLoadMore: _loadNextPage,
                    )),
        ],
      ),
    );
  }
}
