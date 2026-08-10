import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:my_dic/core/presentation/custom_floating_button_location.dart';
import 'package:my_dic/core/presentation/state/query_state.dart';
import 'package:my_dic/core/shared/consts/ui/ui.dart';
import 'package:my_dic/features/word_status/port/presentation_entry.dart';
import 'package:my_dic/features/word_detail/internal/di/view_model_di.dart';
import 'package:my_dic/features/word_detail/internal/presentation/ui_model/jpn_esp_state.dart';
import 'package:my_dic/features/word_detail/internal/presentation/ui_model/word_detail_load_key.dart';
import 'package:my_dic/features/word_detail/internal/presentation/view/esp_jpn/conjugacion_fragment.dart';
import 'package:my_dic/features/word_detail/internal/presentation/view/esp_jpn/dictionary_fragment.dart';
import 'package:my_dic/features/word_detail/internal/presentation/view/jpn_esp/jpn_esp_dictionary_fragment.dart';
import 'package:my_dic/features/word_detail/port/presentation_input.dart';
import 'package:my_dic/features/word_detail/port/word_detail_view_data.dart';
import 'package:my_dic/features/catalog/port/catalog_id.dart';
import 'package:my_dic/features/catalog/port/catalog_word_ref.dart';

//input data DS
//TODO QuizCardState enumを使用してしまってる
class WordDetailFragmentBuilderInput {
  final int wordId;
  final Map<String, Widget> tabs;
  final FloatingActionButton? floatingButton;
  final Widget? statusButton;
  WordDetailFragmentBuilderInput(
      {required this.wordId,
      required this.tabs,
      this.floatingButton,
      required this.statusButton});
}

class TabWordDetailInput {
  final int wordId;
  final Map<String, Widget> tabs;
  final FloatingActionButton? floatingButton;
  final Widget? statusButton;
  TabWordDetailInput(
      {required this.wordId,
      required this.tabs,
      this.floatingButton,
      required this.statusButton});
}

class SingleWordDetailInput {
  final int wordId;
  final Widget body;
  final FloatingActionButton? floatingButton;
  final Widget? statusButton;
  SingleWordDetailInput(
      {required this.wordId,
      required this.body,
      this.floatingButton,
      required this.statusButton});
}

//========input========================================================

//main fragment
//wordId,dictionarytype
class WordDetailFragment extends ConsumerWidget {
  const WordDetailFragment({
    super.key,
    required this.input,
    required this.onOpenQuiz,
  });
  final WordDetailPresentationInput input;
  final void Function(CatalogWordRef word, String? displayHint) onOpenQuiz;

  WordDetailLoadKey get loadKey => WordDetailLoadKey(input.word);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    //TODO ここでデータ取得
    final Map<String, Widget> tabs = {};
    FloatingActionButton? floatingButton;
    Widget? statusButton;

    final pageState = ref.watch(wordDetailViewModelProvider(loadKey));

    final detail = pageState.detail;
    // Status mutations are only meaningful for a confirmed, non-empty
    // primary result.  Do not mount their provider for loading, failure,
    // empty, or stale-data renderer states.
    final viewData =
        detail is QueryData<WordDetailViewData> ? detail.dataOrNull : null;

    switch (viewData) {
      case JpnEspWordDetailViewData():
        tabs['Dictionary'] = JpnEspDictionaryFragment(detail: detail);
        statusButton = DictionaryStatusButtonsEntry(word: input.word);
      case EspJpnWordDetailViewData(conjugation: final conjugation):
        statusButton = DictionaryStatusButtonsEntry(word: input.word);
        tabs['Dictionary'] = EspJpnDictionaryFragment(detail: detail);
        if (conjugation != null) {
          tabs['Conjugacion'] = ConjugacionFragment(
            detail: detail,
            highlight: input.highlight,
          );
          floatingButton = quizFloatingButton(pageState);
        }
      case null:
        if (input.word.catalogId == CatalogId.jpnEspMain) {
          tabs['Dictionary'] = JpnEspDictionaryFragment(detail: detail);
        } else {
          tabs['Dictionary'] = EspJpnDictionaryFragment(detail: detail);
        }
    }

    //TODO 名前とページwidgetつける

    final builderInput = WordDetailFragmentBuilderInput(
        wordId: input.word.wordId,
        tabs: tabs,
        floatingButton: floatingButton,
        statusButton: statusButton);

    return _WordDetailFragmentBuilder(input: builderInput);
  }

  FloatingActionButton quizFloatingButton(WordDetailState pageState) {
    final viewData = pageState.detail.dataOrNull;
    final quizWord = switch (viewData) {
      EspJpnWordDetailViewData(
        entries: final entries,
        conjugation: final conjugation,
      )
          when conjugation != null && entries.isNotEmpty =>
        entries.first.word,
      _ => null,
    };
    return FloatingActionButton(
      onPressed: quizWord == null
          ? null
          : () {
              onOpenQuiz(input.word, quizWord);
            },
      child: const Icon(Icons.handshake_rounded),
    );
  }
}

class _WordDetailFragmentBuilder extends StatelessWidget {
  const _WordDetailFragmentBuilder({required this.input});
  final WordDetailFragmentBuilderInput input;

  @override
  Widget build(BuildContext context) {
    //複数画面を持つか判定
    if (input.tabs.length > 1) {
      final tabInput = TabWordDetailInput(
          wordId: input.wordId,
          tabs: input.tabs,
          floatingButton: input.floatingButton,
          statusButton: input.statusButton);
      return _TabWordDetail(input: tabInput);
    }

    final singleInput = SingleWordDetailInput(
        wordId: input.wordId,
        body: input.tabs.values.first,
        floatingButton: input.floatingButton,
        statusButton: input.statusButton);
    return _SingleWordDetail(input: singleInput);
  }
}

class _TabWordDetail extends ConsumerStatefulWidget {
  const _TabWordDetail({required this.input});
  final TabWordDetailInput input;
  @override
  ConsumerState<_TabWordDetail> createState() => _TabWordDetailState();
}

class _TabWordDetailState extends ConsumerState<_TabWordDetail>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = _createTabController(widget.input.tabs.length);
  }

  @override
  void didUpdateWidget(covariant _TabWordDetail oldWidget) {
    super.didUpdateWidget(oldWidget);

    final tabCount = widget.input.tabs.length;
    if (tabCount == _tabController.length) return;

    final previousIndex = _tabController.index;
    _tabController.removeListener(_tabListener);
    _tabController.dispose();
    _tabController = _createTabController(
      tabCount,
      initialIndex: previousIndex.clamp(0, tabCount - 1).toInt(),
    );
  }

  TabController _createTabController(int length, {int initialIndex = 0}) {
    final controller = TabController(
      length: length,
      vsync: this,
      initialIndex: initialIndex,
    );
    controller.addListener(_tabListener);
    return controller;
  }

  void _tabListener() {
    if (_tabController.indexIsChanging) {}
  }

  @override
  void dispose() {
    _tabController.removeListener(_tabListener);
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final tabs = widget.input.tabs;
    return Scaffold(
      appBar: AppBar(
        title: Text('Word Page'),
        actions: [
          if (widget.input.statusButton case final statusButton?) statusButton,
          if (widget.input.statusButton != null) const SizedBox(width: 14),
        ],
        bottom: TabBar(
          controller: _tabController,
          tabs: tabs.keys.map((title) => Tab(text: title)).toList(),
        ),
      ),
      body: TabBarView(
        //コンテンツ内でpadding,margin調整
        controller: _tabController,
        children: tabs.entries
            .map((entry) => _KeepAlivePage(
                  key: ValueKey(entry.key),
                  child: entry.value,
                ))
            .toList(),
      ),
      floatingActionButton: widget.input.floatingButton,
      floatingActionButtonLocation:
          FloatAboveNavBar(UIConsts.bottomBarCompleteHeight),
      floatingActionButtonAnimator: const NoScaleFloatingActionButtonAnimator(),
    );
  }
}

class _SingleWordDetail extends StatelessWidget {
  const _SingleWordDetail({required this.input});
  final SingleWordDetailInput input;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Word Page'),
        actions: [
          if (input.statusButton case final statusButton?) statusButton,
          if (input.statusButton != null) const SizedBox(width: 14),
        ],
      ),
      body: input.body,
      floatingActionButton: input.floatingButton,
      floatingActionButtonLocation:
          FloatAboveNavBar(UIConsts.bottomBarCompleteHeight),
    );
  }
}

//====================================================
class _KeepAlivePage extends StatefulWidget {
  final Widget child;
  const _KeepAlivePage({super.key, required this.child});

  @override
  State<_KeepAlivePage> createState() => _KeepAlivePageState();
}

class _KeepAlivePageState extends State<_KeepAlivePage>
    with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    super.build(context); // Ensure super.build is called
    return widget.child;
  }
}
