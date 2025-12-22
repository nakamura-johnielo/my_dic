
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:my_dic/Components/status_buttons.dart';
import 'package:my_dic/Constants/Enums/cardState.dart';
import 'package:my_dic/core/common/enums/ui/tab.dart';
import 'package:my_dic/features/quiz/di/view_model_di.dart';
import 'package:my_dic/features/quiz/presentation/view/quiz_game_fragment.dart';
import 'package:my_dic/features/word_page/presentation/view/esp_jpn/conjugacion_fragment.dart';
import 'package:my_dic/features/word_page/presentation/view/esp_jpn/dictionary_fragment.dart';

//input data DS
class EspJpnWordPageFragmentInput {
  final int wordId;
  final bool isVerb;
  EspJpnWordPageFragmentInput({required this.wordId, required this.isVerb});
}

//main fragment
class EspJpnWordPageFragment extends StatelessWidget {
  const EspJpnWordPageFragment({super.key, required this.input});
  final EspJpnWordPageFragmentInput input;

  @override
  Widget build(BuildContext context) {
    if (input.isVerb) {
      return WordPageWithTab(input: input);
    }
    return WordPageWithoutTab(input: input);
  }
}

class WordPageWithTab extends ConsumerStatefulWidget {
  const WordPageWithTab({super.key, required this.input});
  final EspJpnWordPageFragmentInput input;
  @override
  ConsumerState<WordPageWithTab> createState() => _WordPageWithTabState();
}

class _WordPageWithTabState extends ConsumerState<WordPageWithTab>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  //late PageController _pageController;
  //final PageStorageBucket _bucket = PageStorageBucket();
  late EspJpnWordPageFragmentInput input;
  late List<Widget> _tabs;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    // _pageController = PageController();
    _tabController.addListener(_tabListener);
    //input = widget.input;

    //anti rebuild ↓
    _tabs = [
      KeepAlivePage(child: EspJpnDictionaryFragment(wordId: widget.input.wordId)),
      // param1: WordPageChildInputData(wordId: widget.input.wordId))),
      KeepAlivePage(
        child: ConjugacionFragment(wordId: widget.input.wordId),
      )
    ];

    // final dictionaries =
    //     ref.watch(mainViewModelProvider).dictionaryCache[widget.input.wordId]!;
    // if (dictionaries != null && dictionaries.isNotEmpty) {
    //   //!TODO
    //   ref.read(quizWordProvider.notifier).state = dictionaries[0].word;
    // }
  }

  void _tabListener() {
    if (_tabController.indexIsChanging) {
      /* _pageController.animateToPage(
        _tabController.index,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      ); */
    }
    setState(() {});
  }

  @override
  void dispose() {
    _tabController.removeListener(_tabListener);
    _tabController.dispose();
    //_pageController.dispose();
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
          tabs: const [
            Tab(text: 'Dictionary'),
            Tab(text: 'Conjugacion'),
          ],
        ),
      ),
      // PreferredSize(
      //   preferredSize: Size.fromHeight(kToolbarHeight),
      //   child: TabBar(
      //     controller: _tabController,
      //     tabs: [
      //       Tab(text: 'Dictionary'),
      //       Tab(text: 'Conjugacion'),
      //     ],
      //   ),
      // ),
      body: TabBarView(
        //index: _tabController.index,
        //コンテンツ内でpadding,margin調整
        controller: _tabController,
        children: _tabs,
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          ref.read(quizGameViewModelProvider.notifier).initialize();
          ref.read(quizCardStateProvider.notifier).state =
              QuizCardState.question;
          context.push('/${ScreenTab.quiz}/${ScreenPage.quizDetail}',
              extra: QuizGameFragmentInput(
                  wordId: widget.input.wordId,
                  word: widget.input.wordId.toString()));

          // int newIndex = RandomUtils.nextInt(0, 2);
          // log('FAB pressed, switching to tab $newIndex');
          // _tabController.animateTo(newIndex);
        },
        child: const Icon(Icons.handshake_rounded),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.miniEndFloat,
    );
  }
}

class WordPageWithoutTab extends StatelessWidget {
  const WordPageWithoutTab({super.key, required this.input});
  final EspJpnWordPageFragmentInput input;

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
      body: EspJpnDictionaryFragment(wordId: input.wordId),
    );
  }
}

class KeepAlivePage extends StatefulWidget {
  final Widget child;
  const KeepAlivePage({super.key, required this.child});

  @override
  State<KeepAlivePage> createState() => KeepAlivePageState();
}

class KeepAlivePageState extends State<KeepAlivePage>
    with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    super.build(context); // Ensure super.build is called
    return widget.child;
  }
}
