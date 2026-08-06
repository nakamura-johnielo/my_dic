import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:my_dic/core/presentation/components/auto_focus_text_field.dart';
import 'package:my_dic/core/shared/enums/ui/word_status_type.dart';
import 'package:my_dic/features/quiz/presentation/components/quiz_search_card.dart';
import 'package:my_dic/core/domain/entity/verb/conjugacion/conjugacion_search_result_item.dart';
import 'package:my_dic/features/quiz/di/view_model_di.dart';
import 'package:my_dic/core/presentation/components/infinityscroll.dart';
import 'package:my_dic/app/routing/contracts/quiz_game_route.dart';
import 'package:my_dic/core/shared/utils/logger.dart';
import 'package:my_dic/features/search/presentation/components/card/card_view.dart';

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
  late final InfinityScrollController _infinityScrollController;

  @override
  void initState() {
    super.initState();
    _infinityScrollController = InfinityScrollController();
  }

  Future<bool> loadNextPage(int nextPage) async {
    final viewModel = ref.read(quizSearchViewModelProvider.notifier);

    _setCurrentItemLength();

    AppLogger.print("nextpage: $nextPage");
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

  void onTap(ConjugacionSearchResultItem quizWord) {
    final int id = quizWord.wordId;

    //Quiz game の初期化
    ref.read(quizGameViewModelProvider.notifier).initialize();

    ref.read(quizWordProvider.notifier).state = quizWord.word;

    //TODO gorouter check

    ref
        .read(quizSearchViewModelProvider.notifier)
        .goToQuiz(QuizGameRoute(wordId: id, word: quizWord.word));
  }

  @override
  Widget build(BuildContext context) {
    final viewModel = ref.watch(quizSearchViewModelProvider);
    final viewModelNotifier = ref.read(quizSearchViewModelProvider.notifier);

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
                viewModelNotifier.updateQuery(value);
                viewModelNotifier.clearResults();
                _resetPage();
                loadNextPage(_initialPage);
              },
            ),
          ),
          Expanded(
              child: InfinityScrollListView(
            padding: const EdgeInsets.symmetric(horizontal: 10),
            initialPage: _initialPage,
            controller: _infinityScrollController,
            itemCount: viewModel.quizSearchedItems.length,
            itemBuilder: (context, index) {
              final quizWord = viewModel.quizSearchedItems[index];
              return Padding(
                padding: const EdgeInsets.only(bottom: 11),
                child: CardView(
                  wordStatusType: WordStatusType.espJpnWord,
                  goToQuiz: () => onTap(quizWord),
                  query: viewModel.query,
                  wordId: quizWord.wordId, //jpnEspWord.id,
                  ranking: viewModel.rankingNos[quizWord.wordId], //TODO ranking
                  rankingON: true,
                  // conjugations: index % 3 == 0
                  //     ? "現在-yo: soy  現在-yo: soy  現在-yo: soy  現在-yo: soy  現在-yo: soy"
                  //     : null,

                  word: quizWord.word,
                  meaning: quizWord.simpleMeaning,
                  isBookmarked: false,
                  isLearned: false,
                  onTap: () => onTap(quizWord),
                ),
              );
            },
            onLoadMore: loadNextPage,
          )),
        ],
      ),
    );
  }
}
