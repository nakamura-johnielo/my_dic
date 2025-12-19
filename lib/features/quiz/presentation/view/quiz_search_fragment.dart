import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:my_dic/Components/auto_focus_text_field.dart';
import 'package:my_dic/Components/searhCard/conjugacion_search_card.dart';
import 'package:my_dic/Components/searhCard/jpn_esp_searh_card.dart';
import 'package:my_dic/Components/searhCard/quiz_search_card.dart';
import 'package:my_dic/Components/searhCard/search_card.dart';
import 'package:my_dic/Constants/Enums/cardState.dart';
import 'package:my_dic/_Business_Rule/_Domain/Entities/quiz_searched_item.dart';
import 'package:my_dic/_View/search/infinity_scroll_view/infinity_scroll_view_new.dart';
import 'package:my_dic/core/common/enums/ui/tab.dart';
import 'package:my_dic/features/quiz/di/view_model_di.dart';
import 'package:my_dic/features/quiz/presentation/view/quiz_game_fragment.dart';
import 'package:my_dic/features/search/di/view_model_di.dart';
import 'package:my_dic/features/search/presentation/view_model/buffer_controller.dart';
// import 'package:my_dic/_View/search/infinity_scroll_view/infinity_scroll_view.dart';
import 'package:my_dic/_View/word_page/jpn_esp/jpn_esp_word_page_fragment.dart';
import 'package:my_dic/_View/word_page/word_page_fragment.dart';



class QuizSearchFragment extends ConsumerStatefulWidget {
  const QuizSearchFragment({super.key});

  @override
  ConsumerState<QuizSearchFragment> createState() => _QuizSearchFragmentState();
}

class _QuizSearchFragmentState extends ConsumerState<QuizSearchFragment> {
  int _currentPage = -1;
  final int _size = 30; //searchの1ページの取得件数
  int _previousItemLength = 0;
  bool _hasMore = true;

  void loadNextPage() async {
    print("_loadNextPage: $_currentPage");
    if (ref.read(quizSearchViewModelProvider).isLoading) return;

    final viewModel = ref.read(quizSearchViewModelProvider.notifier);

    _setCurrentItemLength();

    await viewModel.loadSearchResults(
      _size,
      _currentPage,
    );

    print(viewModel.state.quizSearchedItems.length);

    final canFetch = _canFetch();

    setState(() {
      _hasMore = canFetch;
      _currentPage++;
    });
  }

  void _resetPage() {
    setState(() {
      _previousItemLength = 0;
      _currentPage = -1;
    });
  }

  void _setCurrentItemLength() {//TODO read watch
    final viewModel = ref.read(quizSearchViewModelProvider);
    _previousItemLength = viewModel.quizSearchedItems.length;
  }

  bool _canFetch() {//TODO read watch
    final viewModel = ref.read(quizSearchViewModelProvider);
    final currentItemLength = viewModel.quizSearchedItems.length;
    return currentItemLength > _previousItemLength;
  }

  void onTap(QuizSearchedItem quizWord) {
    final int id = quizWord.wordId;

    //Quiz game の初期化
    //TODO: quizStateProvider  -> viewmodel
    ref.read(quizGameViewModelProvider.notifier).initialize();
    
    ref.read(quizStateProvider.notifier).init();
    ref.read(quizCardStateProvider.notifier).state = QuizCardState.question;
    ref.read(quizWordProvider.notifier).state = quizWord.word;
 
    context.push('/${ScreenTab.quiz}/${ScreenPage.quizDetail}',
        extra: QuizGameFragmentInput(wordId: id, word: quizWord.word));

  }

  @override
  Widget build(BuildContext context) {
    // final BufferController bufferController =
    //     ref.read(bufferControllerProvider);
    //final int size = 30;

    //final viewModel = ref.watch(searchViewModelProviderOld);
    final viewModel = ref.watch(quizSearchViewModelProvider);
    final viewModelNotifier = ref.read(quizSearchViewModelProvider.notifier);
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
                loadNextPage();
                //});
                //viewModel.query = value;
                //_bufferController.searchWord(value);
              },
            ),
          ),
          Expanded(
              child: InfinityScrollListView(
            hasMore: _hasMore,
            itemCount: viewModel.quizSearchedItems.length,
            itemBuilder: (context, index) {
              final quizWord = viewModel.quizSearchedItems[index];
              return QuizSearchCard(
                word: quizWord.word,
                meaning: quizWord.simpleMeaning,
                //meaning: viewModel.filteredItems[index].meaning,
                onTap: () => onTap(quizWord),
              );
            },
            onLoadMore: loadNextPage,
          )),
        ],
      ),
    );
  }
}
