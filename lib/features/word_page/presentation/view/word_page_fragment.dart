import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:my_dic/core/presentation/custom_floating_button_location.dart';
import 'package:my_dic/core/shared/consts/ui/ui.dart';
import 'package:my_dic/features/word_status/domain/dictionary_direction.dart';
import 'package:my_dic/app/presentation/word_status_buttons.dart';
import 'package:my_dic/features/quiz/consts/card_state.dart';
import 'package:my_dic/app/presentation/quiz_view_models.dart';
import 'package:my_dic/core/shared/enums/word/word_type.dart';
import 'package:my_dic/app/routing/contracts/quiz_game_route.dart';
import 'package:my_dic/app/routing/contracts/word_detail_route.dart';
import 'package:my_dic/features/word_page/di/view_model_di.dart';
import 'package:my_dic/features/word_page/presentation/ui_model/word_page_load_key.dart';
import 'package:my_dic/features/word_page/presentation/ui_model/jpn_esp_state.dart';
import 'package:my_dic/features/word_page/presentation/view/esp_jpn/conjugacion_fragment.dart';
import 'package:my_dic/features/word_page/presentation/view/esp_jpn/dictionary_fragment.dart';
import 'package:my_dic/features/word_page/presentation/view/jpn_esp/jpn_esp_dictionary_fragment.dart';

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

  WordPageLoadKey get loadKey => WordPageLoadKey(
        wordId: input.wordId,
        wordType: input.wordType,
        hasConj: input.hasConj,
      );

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    //TODO ここでデータ取得
    final Map<String, Widget> tabs = {};
    FloatingActionButton? floatingButton;
    Widget? statusButton;

    final pageState = ref.watch(wordPageViewModelProvider(loadKey));

    if (input.wordType == WordType.jpnEsp) {
      tabs["Dictionary"] = JpnEspDictionaryFragment(loadKey: loadKey);
      statusButton = DictionaryStatusButtons(
        wordId: input.wordId,
        direction: DictionaryDirection.jpnEsp,
      );
    } else if (input.wordType == WordType.espJpn) {
      statusButton = DictionaryStatusButtons(
        wordId: input.wordId,
        direction: DictionaryDirection.espJpn,
      );
      tabs["Dictionary"] = EspJpnDictionaryFragment(loadKey: loadKey);
      if (input.hasConj) {
        tabs["Conjugacion"] = ConjugacionFragment(loadKey: loadKey);
        floatingButton = quizFloatingButton(context, ref, pageState);
      }
    }

    //TODO 名前とページwidgetつける

    final builderInput = WordPageFragmentBuilderInput(
        wordId: input.wordId,
        tabs: tabs,
        floatingButton: floatingButton,
        statusButton: statusButton ?? SizedBox.shrink());

    return _WordPageFragmentBuilder(input: builderInput);
  }

  FloatingActionButton quizFloatingButton(
    BuildContext context,
    WidgetRef ref,
    WordPageState pageState,
  ) {
    final dictionaries = pageState.espJpnDictionary.dataOrNull;
    final quizWord = dictionaries != null && dictionaries.isNotEmpty
        ? dictionaries.first.word
        : null;
    return FloatingActionButton(
      onPressed: quizWord == null
          ? null
          : () {
              ref.read(quizCardStateProvider.notifier).state =
                  QuizCardState.question;
              final viewModel =
                  ref.read(wordPageViewModelProvider(loadKey).notifier);
              viewModel.goToQuiz(
                  QuizGameRoute(wordId: input.wordId, word: quizWord));
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
  late List<Widget> _tabBodies;
  late List<Widget> _tabBars;

  @override
  void initState() {
    super.initState();

    _tabController =
        TabController(length: widget.input.tabs.keys.length, vsync: this);
    _tabController.addListener(_tabListener);

    _tabBodies =
        widget.input.tabs.values.map((t) => _KeepAlivePage(child: t)).toList();
    _tabBars = widget.input.tabs.keys.map((t) => Tab(text: t)).toList();
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
          tabs: _tabBars,
        ),
      ),
      body: TabBarView(
        //コンテンツ内でpadding,margin調整
        controller: _tabController,
        children: _tabBodies,
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
  const _KeepAlivePage({required this.child});

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
