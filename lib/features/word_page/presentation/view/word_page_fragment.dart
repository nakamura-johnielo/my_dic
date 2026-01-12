import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:my_dic/core/presentation/custom_floating_button_location.dart';
import 'package:my_dic/core/shared/consts/ui/ui.dart';
import 'package:my_dic/features/esp_jpn_word_status/components/status_button/status_buttons.dart';
import 'package:my_dic/features/quiz/consts/card_state.dart';
import 'package:my_dic/core/shared/consts/ui/tab.dart';
import 'package:my_dic/core/shared/enums/word/word_type.dart';
import 'package:my_dic/features/quiz/di/view_model_di.dart';
import 'package:my_dic/features/quiz/presentation/view/quiz_game_fragment.dart';
import 'package:my_dic/features/word_page/di/view_model_di.dart';
import 'package:my_dic/features/word_page/presentation/view/esp_jpn/conjugacion_fragment.dart';
import 'package:my_dic/features/word_page/presentation/view/esp_jpn/dictionary_fragment.dart';
import 'package:my_dic/features/word_page/presentation/view/jpn_esp/jpn_esp_dictionary_fragment.dart';

//input data DS
//TODO QuizCardState enumを使用してしまってる
class WordPageInput {
  final int wordId;
  final WordType wordType;
  final bool hasConj;
  WordPageInput({
    required this.wordId,
    required this.wordType,
    required this.hasConj,
  });
}

class WordPageFragmentBuilderInput {
  final int wordId;
  final Map<String, Widget> tabs;
  final FloatingActionButton? floatingButton;
  WordPageFragmentBuilderInput(
      {required this.wordId, required this.tabs, this.floatingButton});
}

class TabWordPageInput {
  final int wordId;
  final Map<String, Widget> tabs;
  final FloatingActionButton? floatingButton;
  TabWordPageInput(
      {required this.wordId, required this.tabs, this.floatingButton});
}

class SingleWordPageInput {
  final int wordId;
  final Widget body;
  final FloatingActionButton? floatingButton;
  SingleWordPageInput(
      {required this.wordId, required this.body, this.floatingButton});
}

//========input========================================================
/* 
    final tabs = {
      "Dictionary": EspJpnDictionaryFragment(wordId: widget.input.wordId),
      "Conjugacion": ConjugacionFragment(wordId: widget.input.wordId),
    };

    final floatingButton = FloatingActionButton(
      onPressed: () {
        ref.read(quizGameViewModelProvider.notifier).initialize();
        ref.read(quizCardStateProvider.notifier).state = QuizCardState.question;
        context.push('/${MainScreenTab.quiz}/${ScreenPage.quizDetail}',
            extra: QuizGameFragmentInput(
                wordId: widget.input.wordId,
                word: widget.input.wordId.toString()));
      },
      child: const Icon(Icons.handshake_rounded),
    );
 */

//main fragment
//wordId,dictionarytype
class WordPageFragment extends ConsumerWidget {
  const WordPageFragment({super.key, required this.input});
  final WordPageInput input;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    //TODO ここでデータ取得
    final Map<String, Widget> tabs = {};
    FloatingActionButton? floatingButton;

    final viewModel =
        ref.read(wordPageViewModelProvider(input.wordId).notifier);

    if (input.wordType == WordType.jpnEsp) {
      viewModel.fetchJpnEspDictionaryById(input.wordId);
      tabs["Dictionary"] = JpnEspDictionaryFragment(wordId: input.wordId);
    } else if (input.wordType == WordType.espJpn) {
      viewModel.fetchEspJpnItemsById(input.wordId);
      tabs["Dictionary"] = EspJpnDictionaryFragment(wordId: input.wordId);
      if (input.hasConj) {
        tabs["Conjugacion"] = ConjugacionFragment(wordId: input.wordId);
        floatingButton = quizFloatingButton(context, ref);
      }
    }

    //TODO 名前とページwidgetつける

    final builderInput = WordPageFragmentBuilderInput(
        wordId: input.wordId, tabs: tabs, floatingButton: floatingButton);

    return _WordPageFragmentBuilder(input: builderInput);
  }

  FloatingActionButton quizFloatingButton(BuildContext context, WidgetRef ref) {
    return FloatingActionButton(
      onPressed: () {
        ref.read(quizGameViewModelProvider.notifier).initialize();
        ref.read(quizCardStateProvider.notifier).state = QuizCardState.question;
        //TODO gorouter check
        final viewModel =
            ref.read(wordPageViewModelProvider(input.wordId).notifier);
        viewModel.goToQuiz(QuizGameFragmentInput(
            wordId: input.wordId, word: input.wordId.toString()));
        //context.push('/${MainScreenTab.quiz}/${ScreenPage.quizDetail}',
        // context.push('${StudyScreenPage.flashCard.name}',
        //     extra: QuizGameFragmentInput(
        //         wordId: input.wordId, word: input.wordId.toString()));
      },
      child: const Icon(Icons.handshake_rounded),
    );
  }
}

class _WordPageFragmentBuilder extends StatelessWidget {
  const _WordPageFragmentBuilder({super.key, required this.input});
  final WordPageFragmentBuilderInput input;

  @override
  Widget build(BuildContext context) {
    //複数画面を持つか判定
    if (input.tabs.length > 1) {
      final tabInput = TabWordPageInput(
          wordId: input.wordId,
          tabs: input.tabs,
          floatingButton: input.floatingButton);
      return _TabWordPage(input: tabInput);
    }

    final singleInput = SingleWordPageInput(
        wordId: input.wordId,
        body: input.tabs.values.first,
        floatingButton: input.floatingButton);
    return _SingleWordPage(input: singleInput);
  }
}

class _TabWordPage extends ConsumerStatefulWidget {
  const _TabWordPage({super.key, required this.input});
  // final Map<String, Widget> tabs;
  final TabWordPageInput input;
  @override
  ConsumerState<_TabWordPage> createState() => _TabWordPageState();
}

class _TabWordPageState extends ConsumerState<_TabWordPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  //late PageController _pageController;
  //final PageStorageBucket _bucket = PageStorageBucket();
  // late TabWordPageInput input;
  late List<Widget> _tabBodies;
  late List<Widget> _tabBars;
  // late Map<String, Widget> tabs; //TODO 名前とページwidgetつける
  // late FloatingActionButton floatingButton;

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
    if (_tabController.indexIsChanging) {
      /* _pageController.animateToPage(
        _tabController.index,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      ); */
    }
    //setState(() {});
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
          StatusButtons(wordId: widget.input.wordId),
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
          floatingActionButtonAnimator:const NoScaleFloatingActionButtonAnimator(),
   
    );
  }
}

class _SingleWordPage extends StatelessWidget {
  const _SingleWordPage({super.key, required this.input});
  final SingleWordPageInput input;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Word Page'),
        actions: [
          StatusButtons(wordId: input.wordId),
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
