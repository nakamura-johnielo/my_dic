import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:my_dic/core/presentation/custom_floating_button_location.dart';
import 'package:my_dic/core/shared/consts/ui/ui.dart';
import 'package:my_dic/features/my_word/presentation/ui_model/my_word_ui_model.dart';
import 'package:my_dic/features/my_word/presentation/view/my_word_card.dart';
import 'package:my_dic/features/my_word/presentation/view/my_word_card_modal.dart';
import 'package:my_dic/core/shared/enums/ui/word_card_view_click_listener.dart';
import 'package:my_dic/features/my_word/di/view_model_di.dart';
import 'package:my_dic/features/my_word/presentation/view/create_word_modal.dart';
import 'package:my_dic/core/presentation/components/infinityscroll.dart';
import 'package:my_dic/core/presentation/error/app_error_message.dart';
import 'package:my_dic/core/presentation/state/query_state.dart';

class MyWordFragment extends ConsumerStatefulWidget {
  const MyWordFragment({super.key});

  @override
  ConsumerState<MyWordFragment> createState() => _MyWordFragmentState();
}

class _MyWordFragmentState extends ConsumerState<MyWordFragment> {
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
    final viewModel = ref.read(myWordFragmentViewModelProvider.notifier);

    _setCurrentItemLength();

    await viewModel.loadNext(
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
    });
  }

  void _reloadMyWords() {
    ref.read(myWordFragmentViewModelProvider.notifier).reset();
    _resetPage();
  }

  void _setCurrentItemLength() {
    final viewModel = ref.read(myWordFragmentViewModelProvider);
    _previousItemLength = viewModel.myWordIds.length;
  }

  bool _canFetch() {
    final viewModel = ref.read(myWordFragmentViewModelProvider);
    final currentItemLength = viewModel.myWordIds.length;
    return currentItemLength > _previousItemLength;
  }

  @override
  Widget build(BuildContext context) {
    final myWordViewModel = ref.watch(myWordFragmentViewModelProvider);

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
      body: _content(myWordViewModel),
      floatingActionButton: RegisterButton(onRegistered: _reloadMyWords),
      floatingActionButtonLocation:
          FloatAboveNavBar(UIConsts.bottomBarCompleteHeight),
      floatingActionButtonAnimator: const NoScaleFloatingActionButtonAnimator(),
    );
  }

  Widget _content(MyWordFragmentState screen) => switch (screen.words) {
        QueryInitial() =>
          const Center(child: Text('My Word will load shortly.')),
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
                padding: const EdgeInsets.only(
                  bottom: UIConsts.bottomBarCompleteHeight * 2, // FAB分の余白
                ),
                initialPage: _initialPage,
                controller: _infinityScrollController,
                autoLoadFirstPage: true,
                onLoadMore: loadNextPage,
                itemCount: data.ids.length,
                itemBuilder: (context, index) {
                  final id = data.ids[index];

                  final itemAsync = ref.watch(myWordItemUiModelProvider(id));

                  return itemAsync.when(
                    loading: () => const SizedBox(height: 1),
                    error: (_, __) => const SizedBox(height: 1),
                    data: (item) {
                      if (item == null) return const SizedBox(height: 1);
                      final clickListeners = {
                        WordCardViewButton.bookmark: () => ref
                            .read(myWordStatusCommandProvider(id).notifier)
                            .toggleBookmark(item.isBookmarked),
                        WordCardViewButton.learned: () => ref
                            .read(myWordStatusCommandProvider(id).notifier)
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
          ),
      };

  void _retry() {
    ref.read(myWordFragmentViewModelProvider.notifier).retry(_size);
  }
}

void openDetailModal(
  BuildContext context,
  Map<WordCardViewButton, void Function()> clickListeners,
  int index,
  MyWordItemUiModel item, {
  VoidCallback? onChanged,
}) {
  showDialog<void>(
    context: context,
    barrierDismissible: true, // カード外タップで閉じる
    barrierColor: Colors.black.withValues(alpha: 0.5),
    builder: (context) {
      return Center(
        child: Padding(
          // キーボード表示時の押し上げ対応
          padding: MediaQuery.viewInsetsOf(context),
          child: ConstrainedBox(
            constraints: const BoxConstraints(
              maxWidth: 560, // 必要に応じて調整
            ),
            child: Material(
              type: MaterialType.transparency,
              child: MyWordCardModal(
                item: item,
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
  const RegisterButton({super.key, this.onRegistered});

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
                    type: MaterialType.transparency, // Material 祖先を提供
                    child: WordRegistrationModal(onRegistered: onRegistered),
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
  const RegisterButton2({super.key});

  @override
  Widget build(BuildContext context) {
    return FloatingActionButton(
      onPressed: () {
        // ボタンが押された時のアクション
        showDialog<void>(
            context: context,
            barrierDismissible: true, // カード外タップで閉じる
            builder: (context) {
              return WordRegistrationModal();
            });
      },
      child: Icon(Icons.add),
    );
  }
}
