import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:my_dic/Components/auto_focus_text_field.dart';
import 'package:my_dic/Components/searhCard/conjugacion_search_card.dart';
import 'package:my_dic/Components/searhCard/jpn_esp_searh_card.dart';
import 'package:my_dic/Components/searhCard/search_card.dart';
import 'package:my_dic/_View/search/infinity_scroll_view/infinity_scroll_view_new.dart';
import 'package:my_dic/core/common/enums/ui/tab.dart';
import 'package:my_dic/features/search/di/view_model_di.dart';
import 'package:my_dic/features/search/presentation/view_model/buffer_controller.dart';
// import 'package:my_dic/_View/search/infinity_scroll_view/infinity_scroll_view.dart';
import 'package:my_dic/_View/word_page/jpn_esp/jpn_esp_word_page_fragment.dart';
import 'package:my_dic/_View/word_page/word_page_fragment.dart';

// class MyTextField extends ConsumerWidget {
//   const MyTextField({super.key});

//   @override
//   Widget build(BuildContext context, WidgetRef ref) {
//     final viewModel = ref.watch(searchViewModelProvider);
//     log("1-1 txtfield in build");
//     return TextField(
//       autofocus: true,
//       decoration: InputDecoration(
//         labelText: 'Search',
//         border: OutlineInputBorder(),
//       ),
//       onChanged: (value) {
//         SchedulerBinding.instance.addPostFrameCallback((_) {
//           viewModel.query = value;
//         });
//         //viewModel.query = value;
//         //_bufferController.searchWord(value);
//       },
//     );
//   }
// }

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
  bool _hasMore = true;

  void _loadNextPage() async {
    print("_loadNextPage: $_currentPage");
    if (ref.read(searchViewModelProvider).isLoading) return;

    final viewModel = ref.read(searchViewModelProvider.notifier);

    _setCurrentItemLength();
    await viewModel.loadSearchResults(
      _size,
      _currentPage,
    );
    print(viewModel.state.espJpnWords.length);
    final canFetch = _canFetch();
    setState(() {
      _hasMore = canFetch;
      _currentPage++;
    });
  }

  void _resetPage() {
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
                _loadNextPage();
                //});
                //viewModel.query = value;
                //_bufferController.searchWord(value);
              },
            ),
          ),
          Expanded(
              child: viewModel.jpnEspWords.isNotEmpty
                  ? InfinityScrollListView(
                      hasMore: _hasMore,
                      itemCount: viewModel.jpnEspWords.length,
                      itemBuilder: (context, index) {
                        final jpnEspWord = viewModel.jpnEspWords[index];
                        return JpnEspSearchCard(
                          word: jpnEspWord.word,
                          onTap: () {
                            context.push(
                                '/${ScreenTab.search}/${ScreenPage.jpnEspDetail}',
                                extra: JpnEspWordPageFragmentInput(
                                    wordId: jpnEspWord.id));
                          },
                        );
                      },
                      onLoadMore: _loadNextPage,
                    )
                  : InfinityScrollListView(
                      hasMore: _hasMore,
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
                              context.push(
                                  '/${ScreenTab.search}/${ScreenPage.detail}',
                                  extra: WordPageFragmentInput(
                                      wordId: conjugacion.wordId,
                                      isVerb: true));
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
                            context.push(
                                '/${ScreenTab.search}/${ScreenPage.detail}',
                                extra: WordPageFragmentInput(
                                    wordId: espJpnWord.wordId,
                                    isVerb: espJpnWord.hasVerb()));
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
