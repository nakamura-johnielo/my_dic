import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:my_dic/Components/modal/ranking_filter_modal.dart';
import 'package:my_dic/Components/ranking_card.dart';
import 'package:my_dic/Constants/Enums/word_card_view_click_listener.dart';
import 'package:my_dic/Constants/tab.dart';
import 'package:my_dic/DI/product.dart';
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
  /* Timer? _nextThrottle;
  Timer? _previousThrottle; */
  late final RankingController _rankingController;
  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);

    //final viewModel = ref.read(rankingViewModelProvider);

    /* LoadRankingsControllerInputData inputLoadItems =
        LoadRankingsControllerInputData(
            viewModel.partOfSpeechFilters,
            viewModel.featureTagFilters,
            viewModel.currentPage[1],
            viewModel.size); */
    _rankingController = widget._rankingController;
    widget._rankingController.loadNext();
  }

  void _onScroll() {
    final viewModel = ref.read(rankingViewModelProvider);
    // 最大スクロール位置の80%を計算
    //listviewのbottom padding引いてる240
    //final threshold = _scrollController.position.maxScrollExtent * 0.8 - 240;
    final threshold = _scrollController.position.maxScrollExtent - 540;

    if ( //(!(_nextThrottle?.isActive ?? false)) &&
        _scrollController.position.pixels >= threshold &&
            viewModel.hasNext &&
            !viewModel.isNextLoading) {
      /* LoadRankingsControllerInputData inputLoadItems =
          LoadRankingsControllerInputData(
              viewModel.partOfSpeechFilters,
              viewModel.featureTagFilters,
              viewModel.currentPage[1],
              viewModel.size); */

      viewModel.isNextLoading = true;
      /* _nextThrottle = Timer(Duration(milliseconds: 1200), () {
        //２００ｍｓ以内は受け付けない
      }); */
      widget._rankingController.loadNext();
    }

    final thresholdPre = _scrollController.position.maxScrollExtent * 0.2;
    if ( //(_previousThrottle?.isActive ?? false) &&
        _scrollController.position.pixels <= thresholdPre &&
            viewModel.hasPrevious() &&
            !viewModel.isPreLoading) {
      //_previousThrottle = Timer(Duration(milliseconds: 200), () {});
      /* LoadRankingsControllerInputData inputLoadItems =
          LoadRankingsControllerInputData(
              viewModel.partOfSpeechFilters,
              viewModel.featureTagFilters,
              viewModel.currentPage[1],
              viewModel.size); */
      viewModel.isPreLoading = true;
      //widget._rankingController.loadPrevious();
    }
  }

  /*  void _scrollToTop() {
    _scrollController.animateTo(
      0.0, // 初期値 (一番上) の位置
      duration: Duration(milliseconds: 200), // アニメーションの時間
      curve: Curves.easeInOut, // アニメーションの曲線
    );
  } */

  @override
  void dispose() {
    _scrollController.dispose();
    //_nextThrottle?.cancel();
    //_previousThrottle?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final viewModel = ref.watch(rankingViewModelProvider);
    //widget._rankingController.loadNext(viewModel.page, viewModel.size);
    const margin = EdgeInsets.symmetric(vertical: 1, horizontal: 16);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Ranking'),
      ),
      body: Column(
        children: [
          SizedBox(
            height: 12,
          ),
          Header(margin: margin),
          /* SizedBox(
            height: 2,
          ), */
          if (viewModel.items.isEmpty)
            Expanded(
                child: Center(
              child: Text("Loading..."),
            ))
          else
            Expanded(
              child: ListView.builder(
                padding: EdgeInsets.only(top: 4, bottom: 240),
                controller: _scrollController,
                itemCount: viewModel.items.length,
                itemBuilder: (context, index) {
                  final ranking = viewModel.items[index];
                  Map<WordCardViewButton, VoidCallback>? clickListeners = {
                    WordCardViewButton.bookmark: () {
                      _rankingController.updateWordStatus(
                          index,
                          ranking.wordId,
                          !ranking.isBookmarked,
                          ranking.isLearned,
                          ranking.hasNote);
                    },
                    WordCardViewButton.learned: () {
                      _rankingController.updateWordStatus(
                          index,
                          ranking.wordId,
                          ranking.isBookmarked,
                          !ranking.isLearned,
                          ranking.hasNote);
                    },
                    WordCardViewButton.note: () => log("note clicked"),
                  };

                  return RankingCard(
                    ranking: ranking,
                    margin: margin,
                    onTap: () {
                      context.push('/${ScreenTab.ranking}/${ScreenPage.detail}',
                          extra: WordPageFragmentInput(
                              wordId: ranking.wordId, isVerb: ranking.hasConj));
                    },
                    clickListeners: clickListeners,
                  );
                },
              ),
            ),
        ],
      ),
      floatingActionButton: FilterButton(),
    );
  }
}

//スマホ用
class Header extends StatelessWidget {
  const Header({super.key, required this.margin});
  final EdgeInsetsGeometry margin;

  @override
  Widget build(BuildContext context) {
    const Color textColor = Colors.black;

    return Card(
      margin: margin,
      color: const Color.fromARGB(255, 234, 234, 234),
      elevation: 0,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(6.0),
          topRight: Radius.circular(6.0),
          bottomLeft: Radius.circular(0.0),
          bottomRight: Radius.circular(0.0),
        ),
      ),
      child: Container(
        margin: const EdgeInsets.all(0),
        padding: const EdgeInsets.all(0),
        decoration: BoxDecoration(
          border: Border(
            bottom: BorderSide(
              color: const Color.fromARGB(255, 183, 183, 183),
              width: 2.0,
            ),
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 11, horizontal: 11),
          child: Row(children: [
            SizedBox(
              width: 45,
              child: const Text(
                "No.",
                style: TextStyle(fontSize: 15, color: textColor),
                textAlign: TextAlign.left,
              ),
            ),
            //const SizedBox(width: 15),
            Expanded(
              //width: 160,
              child: const Text(
                "単語",
                style: TextStyle(fontSize: 14, color: textColor),
                textAlign: TextAlign.left,
              ),
            ),
            const SizedBox(width: 5),
            Expanded(
              //width: 160,
              child: const Text(
                "原形",
                style: TextStyle(fontSize: 15, color: textColor),
                textAlign: TextAlign.left,
              ),
            ),
            const SizedBox(width: 54),
          ]),
        ),
      ),
    );
  }
}

/* class Header extends StatelessWidget {
  const Header({super.key, required this.margin});
  final EdgeInsetsGeometry margin;

  @override
  Widget build(BuildContext context) {
    const Color textColor = Colors.black;

    return Card(
      margin: margin,
      color: const Color.fromARGB(255, 234, 234, 234),
      elevation: 0,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(6.0),
          topRight: Radius.circular(6.0),
          bottomLeft: Radius.circular(0.0),
          bottomRight: Radius.circular(0.0),
        ),
      ),
      child: Container(
        margin: const EdgeInsets.all(0),
        padding: const EdgeInsets.all(0),
        decoration: BoxDecoration(
          border: Border(
            bottom: BorderSide(
              color: const Color.fromARGB(255, 183, 183, 183),
              width: 2.0,
            ),
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 11, horizontal: 11),
          child: Row(children: [
            SizedBox(
              width: 45,
              child: const Text(
                "No.",
                style: TextStyle(fontSize: 15, color: textColor),
                textAlign: TextAlign.left,
              ),
            ),
            const SizedBox(width: 15),
            SizedBox(
              width: 160,
              child: const Text(
                "単語",
                style: TextStyle(fontSize: 14, color: textColor),
                textAlign: TextAlign.left,
              ),
            ),
            const SizedBox(width: 15),
            SizedBox(
              width: 160,
              child: const Text(
                "原形",
                style: TextStyle(fontSize: 15, color: textColor),
                textAlign: TextAlign.left,
              ),
            ),
          ]),
        ),
      ),
    );
  }
}
 */

class FilterButton extends StatelessWidget {
  const FilterButton({super.key});

  @override
  Widget build(BuildContext context) {
    return FloatingActionButton(
      onPressed: () {
        // ボタンが押された時のアクション
        showModalBottomSheet<void>(
            context: context,
            backgroundColor: Colors.transparent,
            isScrollControlled: true,
            enableDrag: true,
            //showDragHandle: true,
            barrierColor: Colors.black.withValues(alpha: .5),
            builder: (context) {
              return DI<RankingFilterModal>();
            });
      },
      backgroundColor: Colors.blue,
      child: Icon(Icons.filter_alt_rounded),
    );
  }
}
