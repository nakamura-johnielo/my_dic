import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:my_dic/core/presentation/custom_floating_button_location.dart';
import 'package:my_dic/core/shared/consts/ui/ui.dart';
import 'package:my_dic/features/my_word/internal/presentation/ui_model/my_word_ui_model.dart';
import 'package:my_dic/features/my_word/internal/presentation/view/my_word_card.dart';
import 'package:my_dic/features/my_word/internal/presentation/view/my_word_card_modal.dart';
import 'package:my_dic/core/shared/enums/ui/word_card_view_click_listener.dart';
import 'package:my_dic/features/my_word/internal/presentation/provider/my_word_presentation_providers.dart';
import 'package:my_dic/features/my_word/internal/presentation/view/create_word_modal.dart';
import 'package:my_dic/core/presentation/components/infinityscroll.dart';
import 'package:my_dic/core/presentation/error/app_error_message.dart';
import 'package:my_dic/core/presentation/state/query_state.dart';
import 'package:my_dic/core/session/session_scope_key.dart';
import 'package:my_dic/features/my_word/port/composition.dart';

class MyWordFragment extends ConsumerStatefulWidget {
  const MyWordFragment({super.key, required this.scope, required this.ports});
  final SessionScopeKey scope;
  final MyWordPorts ports;

  @override
  ConsumerState<MyWordFragment> createState() => _MyWordFragmentState();
}

class _MyWordFragmentState extends ConsumerState<MyWordFragment> {
  final int _size = 30; //search の1ページの取得件数
  int _previousItemLength = 0;
  final int _initialPage = 0;
  late final InfinityScrollController _infinityScrollController;

  @override
  void initState() {
    super.initState();
    _infinityScrollController = InfinityScrollController();
  }

  Future<bool> loadNextPage(int nextPage) async {
    final scope = widget.scope;
    final viewModel = ref.read(
        myWordFragmentViewModelProvider((scope: scope, ports: widget.ports))
            .notifier);

    _setCurrentItemLength();

    await viewModel.loadPage(size: _size, page: nextPage);

    final canFetch = _canFetch();

    return canFetch;
  }

  void _resetPage() {
    _infinityScrollController.reset();

    setState(() {
      _previousItemLength = 0;
    });
  }

  void _reloadMyWords() {
    ref
        .read(myWordFragmentViewModelProvider(
            (scope: widget.scope, ports: widget.ports)).notifier)
        .reset();
    _resetPage();
  }

  void _setCurrentItemLength() {
    final viewModel = ref.read(myWordFragmentViewModelProvider(
        (scope: widget.scope, ports: widget.ports)));
    _previousItemLength = viewModel.myWordIds.length;
  }

  bool _canFetch() {
    final viewModel = ref.read(myWordFragmentViewModelProvider(
        (scope: widget.scope, ports: widget.ports)));
    final currentItemLength = viewModel.myWordIds.length;
    return currentItemLength > _previousItemLength;
  }

  @override
  Widget build(BuildContext context) {
    final scope = widget.scope;
    final myWordViewModel = ref.watch(
        myWordFragmentViewModelProvider((scope: scope, ports: widget.ports)));

    return Scaffold(
      appBar: AppBar(
        title: Text('My Word'),
        actions: [
          IconButton(
            icon: Icon(Icons.refresh),
            onPressed: () {
              _reloadMyWords();
            },
          )
        ],
      ),
      body: _content(myWordViewModel, scope),
      floatingActionButton: RegisterButton(
          scope: scope, ports: widget.ports, onRegistered: _reloadMyWords),
      floatingActionButtonLocation:
          FloatAboveNavBar(UIConsts.bottomBarCompleteHeight),
      floatingActionButtonAnimator: const NoScaleFloatingActionButtonAnimator(),
    );
  }

  Widget _content(MyWordFragmentState screen, SessionScopeKey scope) =>
      switch (screen.words) {
        // データが存在する前でもリストをマウントする必要がある。唯一の所有者が自動的に
        // 0 始まりの最初のページを要求する。
        QueryInitial() => _list(const MyWordListResults([]), screen, scope),
        QueryLoading(previousData: null) =>
          const Center(child: CircularProgressIndicator()),
        QueryEmpty() => const Center(child: Text('No saved words yet.')),
        QueryFailure(previousData: null, error: final error) => Center(
            child: Column(mainAxisSize: MainAxisSize.min, children: [
              Text(AppErrorMessage.from(error).text),
              TextButton(onPressed: () => _retry(), child: const Text('Retry')),
            ]),
          ),
        QueryData(value: final data) ||
        QueryLoading(previousData: final data?) ||
        QueryFailure(previousData: final data?, error: _) =>
          _list(data, screen, scope),
      };

  Widget _list(MyWordListResults data, MyWordFragmentState screen,
          SessionScopeKey scope) =>
      Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          for (final warning in screen.words.warnings)
            MaterialBanner(
              content: Text(AppErrorMessage.from(warning.error).text),
              actions: [
                TextButton(onPressed: _retry, child: const Text('Retry')),
              ],
            ),
          if (screen.words
              case QueryFailure(error: final error, previousData: _))
            MaterialBanner(
              content: Text(AppErrorMessage.from(error).text),
              actions: [
                TextButton(onPressed: _retry, child: const Text('Retry'))
              ],
            ),
          Expanded(
              child: InfinityScrollListView(
            // セッションスコープ・エポックは別の結果セットである。キーを振り直した VM がページ 0 を
            // 読み込む間に以前のアカウントの page/hasMore を保持しないよう、スクロール所有者を再マウントする。
            key: ValueKey(scope),
            padding: const EdgeInsets.only(
              bottom: UIConsts.bottomBarCompleteHeight * 2, // FAB 用の余白
            ),
            initialPage: _initialPage,
            controller: _infinityScrollController,
            autoLoadFirstPage: true,
            onLoadMore: loadNextPage,
            itemCount: data.ids.length,
            itemBuilder: (context, index) {
              final id = data.ids[index];

              final itemAsync = ref.watch(myWordItemUiModelProvider(
                  (scope: scope, ports: widget.ports, wordId: id)));

              return itemAsync.when(
                loading: () => const SizedBox(height: 1),
                error: (_, __) => const SizedBox(height: 1),
                data: (item) {
                  if (item == null) return const SizedBox(height: 1);
                  final clickListeners = {
                    WordCardViewButton.bookmark: () => ref
                        .read(myWordStatusCommandProvider(
                                (scope: scope, ports: widget.ports, wordId: id))
                            .notifier)
                        .toggleBookmark(item.isBookmarked),
                    WordCardViewButton.learned: () => ref
                        .read(myWordStatusCommandProvider(
                                (scope: scope, ports: widget.ports, wordId: id))
                            .notifier)
                        .toggleLearned(item.isLearned),
                  };
                  return Padding(
                    key: ValueKey('MyWordCard-${item.wordId}'),
                    padding: const EdgeInsets.only(bottom: 7.0),
                    child: MyWordCard(
                      onTap: () => openDetailModal(
                        context,
                        clickListeners,
                        index,
                        item,
                        scope: scope,
                        ports: widget.ports,
                        onChanged: _reloadMyWords,
                      ),
                      item: item,
                      clickListeners: clickListeners,
                    ),
                  );
                },
              );
            },
          )),
        ],
      );

  void _retry() {
    ref
        .read(myWordFragmentViewModelProvider(
            (scope: widget.scope, ports: widget.ports)).notifier)
        .retryFailed();
  }
}

void openDetailModal(
  BuildContext context,
  Map<WordCardViewButton, void Function()> clickListeners,
  int index,
  MyWordItemUiModel item, {
  required SessionScopeKey scope,
  required MyWordPorts ports,
  VoidCallback? onChanged,
}) {
  showDialog<void>(
    context: context,
    barrierDismissible: true, // カード外タップで閉じる
    barrierColor: Colors.black.withValues(alpha: 0.5),
    builder: (context) {
      return Center(
        child: Padding(
          // キーボード表示時の押し上げ対策
          padding: MediaQuery.viewInsetsOf(context),
          child: ConstrainedBox(
            constraints: const BoxConstraints(
              maxWidth: 560, // 必要に応じて調整
            ),
            child: Material(
              type: MaterialType.transparency,
              child: MyWordCardModal(
                item: item,
                scope: scope,
                ports: ports,
                clickListeners: clickListeners,
                index: index,
                onChanged: onChanged,
              ),
            ),
          ),
        ),
      );
    },
  );
}

class RegisterButton extends StatelessWidget {
  const RegisterButton(
      {super.key, required this.scope, required this.ports, this.onRegistered});
  final SessionScopeKey scope;
  final MyWordPorts ports;

  final VoidCallback? onRegistered;

  @override
  Widget build(BuildContext context) {
    return FloatingActionButton(
      onPressed: () {
        showDialog<void>(
          context: context,
          barrierDismissible: true,
          barrierColor: Colors.black.withValues(alpha: 0.5),
          builder: (context) {
            return Center(
              child: Padding(
                // キーボードで押し上げ
                padding: MediaQuery.viewInsetsOf(context),
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 560),
                  child: Material(
                    type: MaterialType.transparency, // Material の祖先を提供
                    child: WordRegistrationModal(
                        scope: scope, ports: ports, onRegistered: onRegistered),
                  ),
                ),
              ),
            );
          },
        );
      },
      child: Icon(Icons.add),
    );
  }
}

class RegisterButton2 extends StatelessWidget {
  const RegisterButton2({super.key, required this.scope, required this.ports});
  final SessionScopeKey scope;
  final MyWordPorts ports;

  @override
  Widget build(BuildContext context) {
    return FloatingActionButton(
      onPressed: () {
        // ボタンが押された時のアクション
        showDialog<void>(
            context: context,
            barrierDismissible: true, // カード外タップで閉じる
            builder: (context) {
              return WordRegistrationModal(scope: scope, ports: ports);
            });
      },
      child: Icon(Icons.add),
    );
  }
}
