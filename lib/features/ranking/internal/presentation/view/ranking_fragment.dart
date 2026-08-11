import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:my_dic/core/presentation/custom_floating_button_location.dart';
import 'package:my_dic/core/shared/consts/ui/ui.dart';
import 'package:my_dic/features/ranking/internal/presentation/view/ranking_filter_modal.dart';
import 'package:my_dic/features/catalog/port/catalog_id.dart';
import 'package:my_dic/features/catalog/port/catalog_word_ref.dart';
import 'package:my_dic/features/ranking/internal/presentation/provider/effect_provider.dart';
import 'package:my_dic/features/ranking/internal/presentation/view/ranking_card.dart';
import 'package:my_dic/core/presentation/components/infinityscroll.dart';
import 'package:my_dic/features/ranking/internal/presentation/provider/view_model_di.dart';
import 'package:my_dic/core/presentation/error/app_error_message.dart';
import 'package:my_dic/core/presentation/state/query_state.dart';
import 'package:my_dic/features/ranking/internal/presentation/ui_model/ranking_ui_model.dart';
import 'package:my_dic/core/session/session_scope_provider.dart';

class RankingFragment extends ConsumerStatefulWidget {
  const RankingFragment({
    super.key,
    required this.onOpenWordDetail,
    required this.onOpenQuiz,
  });

  final ValueChanged<CatalogWordRef> onOpenWordDetail;
  final void Function(CatalogWordRef word, String? displayHint) onOpenQuiz;

  @override
  ConsumerState<RankingFragment> createState() => _RankingFragmentState();
}

class _RankingFragmentState extends ConsumerState<RankingFragment> {
  late final InfinityScrollController _infinityScrollController;
  late final VoidCallback _resetPageCallback; // = _resetPage;

  @override
  void initState() {
    super.initState();
    _infinityScrollController = InfinityScrollController();
    _resetPageCallback = _resetPage;
  }

  Future<bool> loadNextPage(int nextPage) async {
    final scope = ref.read(sessionScopeKeyProvider);
    if (scope == null) return false;
    return ref
        .read(rankingViewModelProvider(scope).notifier)
        .loadNextPage(nextPage);
  }

  Future<void> _retryFailedPage() async {
    final scope = ref.read(sessionScopeKeyProvider);
    if (scope == null) return;
    await ref.read(rankingViewModelProvider(scope).notifier).retry();
  }

  void _resetPage() {
    //TODO filter適応時にreset走らせる
    //TODO　infilistview内のnextpage変更できないからfilter更新時にリセットする
    _infinityScrollController.reset();
  }

  @override
  Widget build(BuildContext context) {
    final scope = ref.watch(sessionScopeKeyProvider);
    if (scope == null) return const Scaffold(body: SizedBox.shrink());
    final viewModel = ref.watch(rankingViewModelProvider(scope));
    const margin = EdgeInsets.symmetric(vertical: 1, horizontal: 16);

    ref.watch(rankingFilterEffectProvider(
        (scope: scope, resetPage: _resetPageCallback)));

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
          Expanded(child: _content(viewModel, margin, scope)),
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

  Widget _content(
    RankingState screen,
    EdgeInsetsGeometry margin,
    Object scopeKey,
  ) {
    final data = screen.rankings.dataOrNull;
    return Stack(
      children: [
        Column(children: [
          for (final warning in screen.rankings.warnings)
            _RetryWarning(
              message: AppErrorMessage.from(warning.error).text,
              onRetry: _retryFailedPage,
            ),
          if (screen.rankings
              case QueryFailure(error: final error, previousData: final _?))
            _RetryWarning(
              message: AppErrorMessage.from(error).text,
              onRetry: _retryFailedPage,
            ),
          Expanded(
            child: InfinityScrollListView(
              key: ValueKey(scopeKey),
              autoLoadFirstPage: true,
              initialPage: screen.pagenationFilter,
              initialHasMore: screen.hasNext,
              controller: _infinityScrollController,
              onLoadMore: loadNextPage,
              itemCount: data?.items.length ?? 0,
              itemBuilder: (context, index) {
                final ranking = data!.items[index];
                return RankingCard(
                  key: ValueKey("ranking-card-${ranking.rankingId}"),
                  ranking: ranking,
                  margin: margin,
                  onOpenQuiz: widget.onOpenQuiz,
                  onTap: () {
                    widget.onOpenWordDetail(CatalogWordRef(
                      catalogId: CatalogId.espJpnMain,
                      wordId: ranking.wordId,
                    ));
                  },
                );
              },
            ),
          ),
        ]),
        if (data == null)
          Positioned.fill(child: _queryStateOverlay(screen.rankings)),
      ],
    );
  }

  Widget _queryStateOverlay(QueryState<RankingResults> rankings) =>
      switch (rankings) {
        QueryInitial() =>
          const Center(child: Text('Rankings will load shortly.')),
        QueryLoading() => const Center(child: CircularProgressIndicator()),
        QueryEmpty() => const Center(child: Text('No rankings found.')),
        QueryFailure(error: final error) => Center(
            child: Column(mainAxisSize: MainAxisSize.min, children: [
              Text(AppErrorMessage.from(error).text),
              TextButton(
                onPressed: _retryFailedPage,
                child: const Text('Retry'),
              ),
            ]),
          ),
        QueryData() => const SizedBox.shrink(),
      };
}

class _RetryWarning extends StatelessWidget {
  const _RetryWarning({required this.message, required this.onRetry});
  final String message;
  final VoidCallback onRetry;
  @override
  Widget build(BuildContext context) => MaterialBanner(
        content: Text(message),
        actions: [TextButton(onPressed: onRetry, child: const Text('Retry'))],
      );
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
