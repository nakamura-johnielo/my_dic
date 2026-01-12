
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:my_dic/core/presentation/components/auto_focus_text_field.dart';
import 'package:my_dic/features/quiz/presentation/components/quiz_search_card.dart';
import 'package:my_dic/features/quiz/domain/entity/quiz_searched_item.dart';
// import 'package:my_dic/_View/search/infinity_scroll_view/infinity_scroll_view_new.dart';
import 'package:my_dic/core/shared/consts/ui/tab.dart';
import 'package:my_dic/features/quiz/di/view_model_di.dart';
import 'package:my_dic/core/presentation/components/infinityscroll.dart';
import 'package:my_dic/features/quiz/presentation/view/quiz_game_fragment.dart';
// import 'package:my_dic/_View/search/infinity_scroll_view/infinity_scroll_view.dart';

class QuizSearchFragment extends ConsumerStatefulWidget {
  const QuizSearchFragment({super.key});

  @override
  ConsumerState<QuizSearchFragment> createState() => _QuizSearchFragmentState();
}

class _QuizSearchFragmentState extends ConsumerState<QuizSearchFragment> {
  int _currentPage = -1;
  final int _size = 30; //searchの1ページの取得件数
  int _previousItemLength = 0;
  final int _initialPage = 0;
  // bool _hasMore = true;
  late final InfinityScrollController _infinityScrollController;

  @override
  void initState() {
    super.initState();
    _infinityScrollController = InfinityScrollController();
  }

  Future<bool> loadNextPage(int nextPage) async {
    final viewModel = ref.read(quizSearchViewModelProvider.notifier);

    _setCurrentItemLength();

    print("nextpage: "+nextPage.toString());
    await viewModel.loadSearchResults(
      _size,
      nextPage - 1,
    );

    final canFetch = _canFetch();

    return canFetch;
  }

  void _resetPage() {
    _infinityScrollController.reset();

    setState(() {
      _previousItemLength = 0;
      _currentPage = -1;
    });
  }

  void _setCurrentItemLength() {
    final viewModel = ref.read(quizSearchViewModelProvider);
    _previousItemLength = viewModel.quizSearchedItems.length;
  }

  bool _canFetch() {
    final viewModel = ref.read(quizSearchViewModelProvider);
    final currentItemLength = viewModel.quizSearchedItems.length;
    return currentItemLength > _previousItemLength;
  }

  void onTap(QuizSearchedItem quizWord) {
    final int id = quizWord.wordId;

    //Quiz game の初期化
    ref.read(quizGameViewModelProvider.notifier).initialize();

    // ref.read(quizStateProvider.notifier).init();
    // ref.read(quizCardStateProvider.notifier).state = QuizCardState.question;
    ref.read(quizWordProvider.notifier).state = quizWord.word;

    //TODO gorouter check
    //context.push('/${MainScreenTab.quiz}/${ScreenPage.quizDetail}',
    ref.read(quizSearchViewModelProvider.notifier).goToQuiz(
        QuizGameFragmentInput(wordId: id, word: quizWord.word));
    // context.push('/${StudyScreenPage.flashCard}',
    //     extra: QuizGameFragmentInput(wordId: id, word: quizWord.word));
  }

  @override
  Widget build(BuildContext context) {
    // final BufferController bufferController =
    //     ref.read(bufferControllerProvider);
    //final int size = 30;

    //final viewModel = ref.watch(searchViewModelProviderOld);
    final viewModel = ref.watch(quizSearchViewModelProvider);
    final viewModelNotifier = ref.read(quizSearchViewModelProvider.notifier);
    //log("0 Fragment in build");

    return Scaffold(
      appBar: AppBar(
        title: Text('Quiz'),
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
                loadNextPage(_initialPage);
                //});
                //viewModel.query = value;
                //_bufferController.searchWord(value);
              },
            ),
          ),
          Expanded(
              child: InfinityScrollListView(
            initialPage: _initialPage,
            controller: _infinityScrollController,
            //hasMore: _hasMore,
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
