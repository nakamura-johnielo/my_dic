import 'dart:async';
import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:my_dic/core/di/ui/ui_di.dart';
import 'package:my_dic/core/presentation/custom_floating_button_location.dart';
import 'package:my_dic/core/shared/consts/ui/ui.dart';
import 'package:my_dic/features/esp_jpn_word_status/di/di.dart';
import 'package:my_dic/features/ranking/presentation/view/ranking_filter_modal.dart';
import 'package:my_dic/core/shared/enums/word/word_type.dart';
import 'package:my_dic/core/di/view_model/view_model.dart';
import 'package:my_dic/features/ranking/presentation/effect_provider.dart';
import 'package:my_dic/features/ranking/presentation/view/ranking_card.dart';
import 'package:my_dic/core/shared/enums/ui/word_card_view_click_listener.dart';
import 'package:my_dic/core/shared/consts/ui/tab.dart';
import 'package:my_dic/core/presentation/components/infinityscroll.dart';
import 'package:my_dic/features/ranking/di/view_model_di.dart';
import 'package:my_dic/features/user/di/service.dart';
import 'package:my_dic/features/user/di/viewmodel.dart';
import 'package:my_dic/features/word_page/presentation/view/word_page_fragment.dart';

class RankingFragment extends ConsumerStatefulWidget {
  const RankingFragment({super.key});

  @override
  ConsumerState<RankingFragment> createState() => _RankingFragmentState();
}

class _RankingFragmentState extends ConsumerState<RankingFragment> {
  int _previousItemLength = 0;
  final int _initialPage = 0;

  late final InfinityScrollController _infinityScrollController;
  late final VoidCallback _resetPageCallback; // = _resetPage;

  @override
  void initState() {
    super.initState();
    _infinityScrollController = InfinityScrollController();
    _resetPageCallback = _resetPage;
  }

  Future<bool> loadNextPage(int nextPage) async {
    final viewModel = ref.read(rankingViewModelProvider.notifier);

    _setCurrentItemLength();
    viewModel.setNextPage(nextPage - 1);

    await viewModel.loadNextPage(nextPage);

    final canFetch = _canFetch();

    return canFetch;
  }

  void _resetPage() {
    //TODO filter適応時にreset走らせる
    //TODO　infilistview内のnextpage変更できないからfilter更新時にリセットする
    _infinityScrollController.reset();

    setState(() {
      _previousItemLength = 0;
    });
  }

  void _setCurrentItemLength() {
    final viewModel = ref.read(rankingViewModelProvider);
    _previousItemLength = viewModel.items.length;
  }

  bool _canFetch() {
    final viewModel = ref.read(rankingViewModelProvider);
    final currentItemLength = viewModel.items.length;
    return currentItemLength > _previousItemLength;
  }

  @override
  Widget build(BuildContext context) {
    final viewModel = ref.watch(rankingViewModelProvider);
    const margin = EdgeInsets.symmetric(vertical: 1, horizontal: 16);

    ref.watch(rankingFilterEffectProvider(_resetPageCallback));

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
          Expanded(
              child: InfinityScrollListView(
            autoLoadFirstPage: true,
            initialPage: _initialPage,
            controller: _infinityScrollController,
            onLoadMore: loadNextPage,
            itemCount: viewModel.items.length,
            itemBuilder: (context, index) {
              final ranking = viewModel.items[index];

              return RankingCard(
                key: ValueKey("ranking-card-${ranking.wordId}"),
                ranking: ranking,
                margin: margin,
                onTap: () {
                  ref.read(rankingViewModelProvider.notifier).goToDetail(
                      WordPageInput(
                          wordId: ranking.wordId,
                          wordType: WordType.espJpn,
                          hasConj: ranking.hasConj));
                },
              );
            },
          )),
        ],
      ),
      floatingActionButton: const FilterButton(
        key: ValueKey("ranking-fl-btn"),
      ),
      floatingActionButtonLocation:
          FloatAboveNavBar(UIConsts.bottomBarCompleteHeight),
      floatingActionButtonAnimator: const NoScaleFloatingActionButtonAnimator(),
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
    return Card(
      margin: margin,
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
            barrierColor: Colors.black.withValues(alpha: .5),
            builder: (context) {
              return RankingFilterModal();
            });
      },
      child: Icon(Icons.filter_alt_rounded),
    );
  }
}
