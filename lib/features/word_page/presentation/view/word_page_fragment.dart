import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:my_dic/core/presentation/custom_floating_button_location.dart';
import 'package:my_dic/core/shared/consts/ui/ui.dart';
import 'package:my_dic/app/presentation/word_status_buttons.dart';
import 'package:my_dic/app/routing/contracts/quiz_game_route.dart';
import 'package:my_dic/app/routing/contracts/word_detail_route.dart';
import 'package:my_dic/app/routing/route_name_resolver.dart';
import 'package:my_dic/core/di/router/router.dart';
import 'package:my_dic/features/word_page/di/view_model_di.dart';
import 'package:my_dic/features/word_page/presentation/ui_model/word_page_load_key.dart';
import 'package:my_dic/features/word_page/presentation/ui_model/jpn_esp_state.dart';
import 'package:my_dic/features/word_page/presentation/view/esp_jpn/conjugacion_fragment.dart';
import 'package:my_dic/features/word_page/presentation/view/esp_jpn/dictionary_fragment.dart';
import 'package:my_dic/features/word_page/presentation/view/jpn_esp/jpn_esp_dictionary_fragment.dart';
import 'package:my_dic/features/word_page/application/query/word_detail_view_data.dart';
import 'package:my_dic/features/catalog/port/catalog_id.dart';

//input data DS
//TODO QuizCardState enumを使用してしまってる
class WordPageFragmentBuilderInput {
  final int wordId;
  final Map<String, Widget> tabs;
  final FloatingActionButton? floatingButton;
  final Widget statusButton;
  WordPageFragmentBuilderInput(
      {required this.wordId,
      required this.tabs,
      this.floatingButton,
      required this.statusButton});
}

class TabWordPageInput {
  final int wordId;
  final Map<String, Widget> tabs;
  final FloatingActionButton? floatingButton;
  final Widget statusButton;
  TabWordPageInput(
      {required this.wordId,
      required this.tabs,
      this.floatingButton,
      required this.statusButton});
}

class SingleWordPageInput {
  final int wordId;
  final Widget body;
  final FloatingActionButton? floatingButton;
  final Widget statusButton;
  SingleWordPageInput(
      {required this.wordId,
      required this.body,
      this.floatingButton,
      required this.statusButton});
}

//========input========================================================

//main fragment
//wordId,dictionarytype
class WordPageFragment extends ConsumerWidget {
  const WordPageFragment({super.key, required this.route});
  final WordDetailRoute route;

  WordDetailRoute get input => route;

  WordPageLoadKey get loadKey => WordPageLoadKey(input.word);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    //TODO ここでデータ取得
    final Map<String, Widget> tabs = {};
    FloatingActionButton? floatingButton;
    Widget? statusButton;

    final pageState = ref.watch(wordPageViewModelProvider(loadKey));

    final detail = pageState.detail;
    final viewData = detail.dataOrNull;

    switch (viewData) {
      case JpnEspWordDetailViewData():
        tabs['Dictionary'] = JpnEspDictionaryFragment(detail: detail);
        statusButton = DictionaryStatusButtons(word: input.word);
      case EspJpnWordDetailViewData(conjugation: final conjugation):
        statusButton = DictionaryStatusButtons(word: input.word);
        tabs['Dictionary'] = EspJpnDictionaryFragment(detail: detail);
        if (conjugation != null) {
          tabs['Conjugacion'] = ConjugacionFragment(detail: detail);
          floatingButton = quizFloatingButton(context, ref, pageState);
        }
      case null:
        if (input.word.catalogId == CatalogId.jpnEspMain) {
          tabs['Dictionary'] = JpnEspDictionaryFragment(detail: detail);
          statusButton = DictionaryStatusButtons(word: input.word);
        } else {
          tabs['Dictionary'] = EspJpnDictionaryFragment(detail: detail);
          statusButton = DictionaryStatusButtons(word: input.word);
        }
    }

    //TODO 名前とページwidgetつける

    final builderInput = WordPageFragmentBuilderInput(
        wordId: input.word.wordId,
        tabs: tabs,
        floatingButton: floatingButton,
        statusButton: statusButton);

    return _WordPageFragmentBuilder(input: builderInput);
  }

  FloatingActionButton quizFloatingButton(
    BuildContext context,
    WidgetRef ref,
    WordPageState pageState,
  ) {
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
              final route = QuizGameRoute(
                wordId: input.word.wordId,
                word: quizWord,
              );
              context.pushNamed(
                quizGameRouteNameFor(ref.read(entryPointProvider)),
                pathParameters: route.pathParameters,
                queryParameters: route.queryParameters,
              );
            },
      child: const Icon(Icons.handshake_rounded),
    );
  }
}

class _WordPageFragmentBuilder extends StatelessWidget {
  const _WordPageFragmentBuilder({required this.input});
  final WordPageFragmentBuilderInput input;

  @override
  Widget build(BuildContext context) {
    //複数画面を持つか判定
    if (input.tabs.length > 1) {
      final tabInput = TabWordPageInput(
          wordId: input.wordId,
          tabs: input.tabs,
          floatingButton: input.floatingButton,
          statusButton: input.statusButton);
      return _TabWordPage(input: tabInput);
    }

    final singleInput = SingleWordPageInput(
        wordId: input.wordId,
        body: input.tabs.values.first,
        floatingButton: input.floatingButton,
        statusButton: input.statusButton);
    return _SingleWordPage(input: singleInput);
  }
}

class _TabWordPage extends ConsumerStatefulWidget {
  const _TabWordPage({required this.input});
  final TabWordPageInput input;
  @override
  ConsumerState<_TabWordPage> createState() => _TabWordPageState();
}

class _TabWordPageState extends ConsumerState<_TabWordPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = _createTabController(widget.input.tabs.length);
  }

  @override
  void didUpdateWidget(covariant _TabWordPage oldWidget) {
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
          widget.input.statusButton,
          SizedBox(
            width: 14,
          )
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

class _SingleWordPage extends StatelessWidget {
  const _SingleWordPage({required this.input});
  final SingleWordPageInput input;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Word Page'),
        actions: [
          input.statusButton,
          SizedBox(
            width: 14,
          )
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
