import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:my_dic/Components/ranking_card.dart';
import 'package:my_dic/Constants/tab.dart';
import 'package:my_dic/DI/product.dart';
import 'package:my_dic/_Business_Rule/_Domain/Entities/ranking.dart';
import 'package:my_dic/_Interface_Adapter/Controller/ranking_controller.dart';
import 'package:my_dic/_Interface_Adapter/ViewModel/ranking_view_model.dart';
import 'package:my_dic/_View/word_page/word_page_fragment.dart';

class RankingFragment extends ConsumerStatefulWidget {
  const RankingFragment(this._rankingController, {super.key});
  final RankingController _rankingController;

  @override
  ConsumerState<RankingFragment> createState() => _RankingFragmentState();
}

class _RankingFragmentState extends ConsumerState<RankingFragment> {
  final ScrollController _scrollController = ScrollController();
  /* final RankingController _rankingController;
   _RankingFragmentState(this._rankingController); */

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
    final viewModel = ref.read(rankingViewModelProvider);
    widget._rankingController.loadNext(viewModel.page, viewModel.size);
  }

  void _onScroll() {
    final viewModel = ref.read(rankingViewModelProvider);
    // 最大スクロール位置の80%を計算
    final threshold = _scrollController.position.maxScrollExtent * 0.8;

    if (_scrollController.position.pixels >= threshold &&
        viewModel.hasNext &&
        !viewModel.isLoading) {
      widget._rankingController.loadNext(viewModel.page, viewModel.size);
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final viewModel = ref.watch(rankingViewModelProvider);
    //widget._rankingController.loadNext(viewModel.page, viewModel.size);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Ranking'),
      ),
      body: ListView.builder(
        controller: _scrollController,
        itemCount: viewModel.items.length,
        itemBuilder: (context, index) {
          final ranking = viewModel.items[index];

          return RankingCard(
            word: ranking.rankedWord,
            original: ranking.lemma,
            no: ranking.rank,
            onTap: () {
              context.push('/${ScreenTab.ranking}/${ScreenPage.detail}',
                  extra: WordPageFragmentInput(
                      wordId: ranking.wordId, isVerb: true));
            },
          );
        },
      ),
    );
  }
}
