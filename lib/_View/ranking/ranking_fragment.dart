import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:my_dic/Components/infinity_list_view.dart';
import 'package:my_dic/Components/modal/ranking_filter_modal.dart';
import 'package:my_dic/Components/ranking_card.dart';
import 'package:my_dic/Components/status_buttons.dart';
import 'package:my_dic/Constants/Enums/word_card_view_click_listener.dart';
import 'package:my_dic/Constants/tab.dart';
import 'package:my_dic/DI/product.dart';
import 'package:my_dic/_Business_Rule/_Domain/Entities/ranking.dart';
import 'package:my_dic/_Interface_Adapter/Controller/ranking_controller.dart';
import 'package:my_dic/_Interface_Adapter/ViewModel/ranking_view_model.dart';
import 'package:my_dic/_Interface_Adapter/ViewModel/user/profile.dart';
import 'package:my_dic/_View/word_page/word_page_fragment.dart';

class RankingFragment extends ConsumerWidget {
  const RankingFragment({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final rankingController = ref.read(rankingControllerProvider);
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
              child: RankingInfinityScrollListView(
            //resetScroll: viewModel.resetIsOnUpdatedFilter,
            // isOnUpdatedFilter: viewModel.isOnUpdatedFilter,
            loadNext: rankingController.loadNext,
            itemCount: viewModel.items.length,
            itemBuilder: (context, index) {
              final id = viewModel.items[index].wordId;
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
class Header extends StatelessWidget {
  const Header({super.key, required this.margin});
  final EdgeInsetsGeometry margin;

  @override
  Widget build(BuildContext context) {
    const Color textColor = Colors.black;

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
