import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:my_dic/Components/modal/ranking_filter_modal.dart';
import 'package:my_dic/Components/ranking_card.dart';
import 'package:my_dic/Constants/Enums/word_card_view_click_listener.dart';
import 'package:my_dic/core/common/enums/ui/tab.dart';
import 'package:my_dic/DI/product.dart';
import 'package:my_dic/core/components/infinityscroll.dart';
import 'package:my_dic/features/ranking/di/view_model_di.dart';
import 'package:my_dic/features/user/di/viewmodel.dart';
import 'package:my_dic/_View/word_page/word_page_fragment.dart';

class RankingFragment extends ConsumerStatefulWidget {
  const RankingFragment({super.key});

  @override
  ConsumerState<RankingFragment> createState() => _RankingFragmentState();
}

class _RankingFragmentState extends ConsumerState<RankingFragment> {
  // int _currentPage = -1;
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
    final rankingController = ref.read(rankingControllerProvider);
    final viewModel = ref.watch(rankingViewModelProvider);

    _setCurrentItemLength();
    viewModel.currentPage = [-1, nextPage - 1];

    await rankingController.loadNext();

    final canFetch = _canFetch();

    return canFetch;
  }

  void _resetPage() {//TODO filter適応時にreset走らせる
    _infinityScrollController.reset();

    setState(() {
      _previousItemLength = 0;
      // _currentPage = -1;
    });
  }

  void _setCurrentItemLength() {
    //TODO read watch
    final viewModel = ref.read(rankingViewModelProvider);
    _previousItemLength = viewModel.items.length;
  }

  bool _canFetch() {
    //TODO read watch
    final viewModel = ref.read(rankingViewModelProvider);
    final currentItemLength = viewModel.items.length;
    return currentItemLength > _previousItemLength;
  }

  @override
  Widget build(BuildContext context) {
    // final rankingController = ref.read(rankingControllerProvider);
    final viewModel = ref.watch(rankingViewModelProvider);
    final wordStatusController = ref.read(wordStatusViewModelProvider.notifier);
    //_rankingController.loadNext();
    const margin = EdgeInsets.symmetric(vertical: 1, horizontal: 16);
    final userId = ref.watch(userViewModelProvider)?.id ?? "anonymous";

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
          /* if (viewModel.items.isEmpty)
            Expanded(
                child: Center(
              child: Text("Loading..."),
            ))
          else */
          Expanded(
              child: InfinityScrollListView(
            autoLoadFirstPage: true,
            initialPage: _initialPage,
            controller: _infinityScrollController,
            onLoadMore: loadNextPage,
            //resetScroll: viewModel.resetIsOnUpdatedFilter,
            // isOnUpdatedFilter: viewModel.isOnUpdatedFilter,
            // loadNext: rankingController.loadNext,
            itemCount: viewModel.items.length,
            itemBuilder: (context, index) {
              final id = viewModel.items[index].wordId;

              //TODO streamproviderで監視
              final wordStatus = ref.watch(wordStatusByIdProvider(id));

              final rankingbase = viewModel.items[index];
              final ranking = rankingbase.copyWith(
                isBookmarked:
                    wordStatus?.isBookmarked ?? rankingbase.isBookmarked,
                isLearned: wordStatus?.isLearned ?? rankingbase.isLearned,
                hasNote: wordStatus?.hasNote ?? rankingbase.hasNote,
              );

              Map<WordCardViewButton, VoidCallback>? clickListeners = {
                WordCardViewButton.bookmark: () {
                  wordStatusController.toggleBookmark(id, userId);
                  //   _rankingController.updateWordStatus(
                  //       index,
                  //       ranking.wordId,
                  //       !ranking.isBookmarked,
                  //       ranking.isLearned,
                  //       ranking.hasNote);
                },
                WordCardViewButton.learned: () {
                  wordStatusController.toggleLearned(id, userId);
                  //   _rankingController.updateWordStatus(
                  //       index,
                  //       ranking.wordId,
                  //       ranking.isBookmarked,
                  //       !ranking.isLearned,
                  //       ranking.hasNote);
                },
                WordCardViewButton.note: () => log("note clicked"),
              };

              return RankingCard(
                ranking: ranking,
                // rankingbase.copyWith(
                //   isBookmarked:
                //       wordStatus?.isBookmarked ?? rankingbase.isBookmarked,
                //   isLearned: wordStatus?.isLearned ?? rankingbase.isLearned,
                // ),
                margin: margin,
                onTap: () {
                  context.push('/${ScreenTab.ranking}/${ScreenPage.detail}',
                      extra: WordPageFragmentInput(
                          wordId: ranking.wordId, isVerb: ranking.hasConj));
                },
                clickListeners: clickListeners,
              );
            },
          )),
        ],
      ),
      floatingActionButton: FilterButton(),
    );
  }
}

//スマホ用
//TODO デザイン変更、幅調整
class Header extends StatelessWidget {
  const Header({super.key, required this.margin});
  final EdgeInsetsGeometry margin;

  @override
  Widget build(BuildContext context) {
    //const Color textColor = Colors.black;

    return Card(
      margin: margin,
      //color: const Color.fromARGB(255, 234, 234, 234),
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
                style: TextStyle(
                  fontSize: 15, //color: textColor
                ),
                textAlign: TextAlign.left,
              ),
            ),
            //const SizedBox(width: 15),
            Expanded(
              //width: 160,
              child: const Text(
                "単語",
                style: TextStyle(
                  fontSize: 14, // color: textColor
                ),
                textAlign: TextAlign.left,
              ),
            ),
            const SizedBox(width: 5),
            Expanded(
              //width: 160,
              child: const Text(
                "原形",
                style: TextStyle(
                  fontSize: 15, //color: textColor
                ),
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
              return RankingFilterModal();
            });
      },
      //backgroundColor: Colors.blue,
      child: Icon(Icons.filter_alt_rounded),
    );
  }
}
