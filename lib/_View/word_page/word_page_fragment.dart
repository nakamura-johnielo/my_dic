import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:my_dic/DI/product.dart';
import 'package:my_dic/_View/word_page/conjugacion_fragment.dart';
import 'package:my_dic/_View/word_page/dictionary_fragment.dart';
import 'package:my_dic/utils/random.dart';

//input data DS
class WordPageFragmentInput {
  final int wordId;
  final bool isVerb;
  WordPageFragmentInput({required this.wordId, required this.isVerb});
}

//main fragment
class WordPageFragment extends StatelessWidget {
  const WordPageFragment({super.key, required this.input});
  final WordPageFragmentInput input;

  @override
  Widget build(BuildContext context) {
    if (input.isVerb) {
      return WordPageWithTab(input: input);
    }
    return WordPageWithoutTab(input: input);
  }
}

class WordPageWithTab extends StatefulWidget {
  const WordPageWithTab({super.key, required this.input});
  final WordPageFragmentInput input;
  @override
  State<WordPageWithTab> createState() => _WordPageWithTabState();
}

class _WordPageWithTabState extends State<WordPageWithTab>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  //late PageController _pageController;
  //final PageStorageBucket _bucket = PageStorageBucket();
  late WordPageFragmentInput input;
  late List<Widget> _tabs;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    // _pageController = PageController();
    _tabController.addListener(_tabListener);
    //input = widget.input;

    //anti rebuild ↓
    //! TODO ただ、isbookmarkedとかの更新に対応する必要あり
    _tabs = [
      KeepAlivePage(
          child: DI<DictionaryFragment>(
              param1: WordPageChildInputData(wordId: widget.input.wordId))),
      KeepAlivePage(
        child: DI<ConjugacionFragment>(
            param1: WordPageChildInputData(wordId: widget.input.wordId)),
      )
    ];
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
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(kToolbarHeight),
        child: TabBar(
          controller: _tabController,
          tabs: [
            Tab(text: 'Dictionary'),
            Tab(text: 'Conjugacion'),
          ],
        ),
      ),
      body: TabBarView(
        //index: _tabController.index,
        //コンテンツ内でpadding,margin調整
        controller: _tabController,
        children: _tabs,
      ),
    );
  }
}

class WordPageWithoutTab extends StatelessWidget {
  const WordPageWithoutTab({super.key, required this.input});
  final WordPageFragmentInput input;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: DI<DictionaryFragment>(
          param1: WordPageChildInputData(wordId: input.wordId)),
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
