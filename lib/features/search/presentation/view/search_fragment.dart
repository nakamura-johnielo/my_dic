import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:my_dic/core/presentation/components/auto_focus_text_field.dart';
import 'package:my_dic/features/search/presentation/components/conjugacion_search_card.dart';
import 'package:my_dic/features/search/presentation/components/jpn_esp_searh_card.dart';
import 'package:my_dic/features/search/presentation/components/search_card.dart';
import 'package:my_dic/core/shared/consts/ui/tab.dart';
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
  // bool _hasMore = true;
  late final InfinityScrollController _infinityScrollController;
  final int initialPage = 0;

  @override
  void initState() {
    super.initState();
    _infinityScrollController = InfinityScrollController();
  }

  Future<bool> _loadNextPage(int nextPage) async {
    print("_loadNextPage: $nextPage");
    //if (ref.read(searchViewModelProvider).isLoading) return;

    final viewModel = ref.read(searchViewModelProvider.notifier);

    _setCurrentItemLength();
    await viewModel.loadSearchResults(
      _size,
      nextPage - 1,
    );
    //print(viewModel.state.espJpnWords.length);
    final canFetch = _canFetch();
    print("canfetch:$canFetch");
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
    print(
        "EspJpn current:$currentEspJpnItemLength, pre:$_previousEspJpnItemLength");
    return currentEspJpnItemLength > _previousEspJpnItemLength ||
        currentConjItemLength > _previousConjItemLength ||
        currentJpnEspItemLength > _previousJpnEspItemLength;
  }

  @override
  Widget build(BuildContext context) {
    // final BufferController bufferController =
    //     ref.read(bufferControllerProvider);
    //final int size = 30;

    //final viewModel = ref.watch(searchViewModelProviderOld);
    final viewModel = ref.watch(searchViewModelProvider);
    final viewModelNotifier = ref.read(searchViewModelProvider.notifier);
    log("0 Fragment in build");

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
                //SchedulerBinding.instance.addPostFrameCallback((_) {
                //viewModel.query = value;
                viewModelNotifier.updateQuery(value);
                viewModelNotifier.clearResults();
                _resetPage();
                // _loadNextPage(initialPage);
                //});
                //viewModel.query = value;
                //_bufferController.searchWord(value);
              },
            ),
          ),
          Expanded(
              child: viewModel.jpnEspWords.isNotEmpty
                  ? InfinityScrollListView(
                      autoLoadFirstPage: true,
                      initialPage: initialPage,
                      controller: _infinityScrollController,
                      itemCount: viewModel.jpnEspWords.length,
                      itemBuilder: (context, index) {
                        final jpnEspWord = viewModel.jpnEspWords[index];
                        return JpnEspSearchCard(
                          word: jpnEspWord.word,
                          onTap: () {
                            // context.push(
                            //     '/${MainScreenTab.search}/${ScreenPage.jpnEspDetail}',
                            //     extra: JpnEspWordPageFragmentInput(
                            //         wordId: jpnEspWord.id));

                            //TODO gorouter check
                            viewModelNotifier.goToWordDetail(WordPageInput(
                                wordId: jpnEspWord.id,
                                wordType: WordType.jpnEsp,
                                hasConj: false));
                            //   context.push(
                            //       // '/${MainScreenTab.search}/${ScreenPage.wordDetail}',
                            //  '${ScreenPage.wordDetail.name}',
                            //       extra: WordPageInput(
                            //           wordId: jpnEspWord.id,
                            //           wordType: WordType.jpnEsp,
                            //           hasConj: false));
                          },
                        );
                      },
                      onLoadMore: _loadNextPage,
                    )
                  : InfinityScrollListView(
                      autoLoadFirstPage: true,
                      initialPage: initialPage,
                      controller: _infinityScrollController,
                      itemCount: (viewModel.conjugacions.length +
                          viewModel.espJpnWords.length),
                      itemBuilder: (context, index) {
                        final conjLength = viewModel.conjugacions.length;
                        final query = viewModel.query;
                        //先にconj
                        if (index < conjLength) {
                          final conjugacion = viewModel.conjugacions[index];
                          return ConjugacionSearchCard(
                            word: conjugacion.word,
                            conjugacions: conjugacion.matches,
                            query: query,
                            //meaning: viewModel.filteredItems[index].meaning,
                            onTap: () {
                              // context.push(
                              //     '/${MainScreenTab.search}/${ScreenPage.detail}',
                              //     extra: EspJpnWordPageFragmentInput(
                              //         wordId: conjugacion.wordId,
                              //         isVerb: true));

                              //TODO gorouter check

                              viewModelNotifier.goToWordDetail(WordPageInput(
                                  wordId: conjugacion.wordId,
                                  wordType: WordType.espJpn,
                                  hasConj: true));
                              // context.push(
                              //     // '/${MainScreenTab.search}/${ScreenPage.wordDetail}',
                              //     '${ScreenPage.wordDetail.name}',
                              //     extra: WordPageInput(
                              //         wordId: conjugacion.wordId,
                              //         wordType: WordType.espJpn,
                              //         hasConj: true));
                            },
                          );
                        }
                        index = index - conjLength;
                        final espJpnWord = viewModel.espJpnWords[index];
                        return SearchCard(
                          word: espJpnWord.word,
                          //meaning: viewModel.filteredItems[index].meaning,
                          partOfSpeech: espJpnWord.partOfSpeech,
                          onTap: () {
                            // context.push(
                            //     '/${MainScreenTab.search}/${ScreenPage.detail}',
                            //     extra: EspJpnWordPageFragmentInput(
                            //         wordId: espJpnWord.wordId,
                            //         isVerb: espJpnWord.hasVerb()));

                            //TODO gorouter check
                            viewModelNotifier.goToWordDetail(WordPageInput(
                                wordId: espJpnWord.wordId,
                                wordType: WordType.espJpn,
                                hasConj: espJpnWord.hasVerb()));
                            // context.push(
                            //     // '/${MainScreenTab.search}/${ScreenPage.wordDetail}',
                            //     '${ScreenPage.wordDetail.name}',
                            //     extra: WordPageInput(
                            //         wordId: espJpnWord.wordId,
                            //         wordType: WordType.espJpn,
                            //         hasConj: espJpnWord.hasVerb()));
                          },
                        );
                      },
                      onLoadMore: _loadNextPage,
                    )),
        ],
      ),
    );
  }
}
