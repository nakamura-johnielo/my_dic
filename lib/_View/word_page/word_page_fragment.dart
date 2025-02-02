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
  final PageStorageBucket _bucket = PageStorageBucket();
  late WordPageFragmentInput input;

  final String key0 = generateUUID();
  final String key1 = generateUUID();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    // _pageController = PageController();
    _tabController.addListener(_tabListener);
    input = widget.input;
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
      body: PageStorage(
        bucket: _bucket,
        child: //IndexedStack(
            TabBarView(
          //index: _tabController.index,
          //コンテンツ内でpadding,margin調整
          controller: _tabController,
          children: [
            /* DI<DictionaryFragment>(
                param1: WordPageChildInputData(
                    wordId: input.wordId, key: PageStorageKey(generateUUID()))),
            DI<ConjugacionFragment>(
                param1: WordPageChildInputData(
                    wordId: input.wordId, key: PageStorageKey(generateUUID()))), */
            DI<DictionaryFragment>(
                param1: WordPageChildInputData(
                    wordId: input.wordId, key: PageStorageKey(key0))),
            DI<ConjugacionFragment>(
                param1: WordPageChildInputData(
                    wordId: input.wordId, key: PageStorageKey(key1))),
          ],
        ),
      ),
      /* Stack(
          children: [
            PageView(
              controller: _pageController,
              onPageChanged: (index) {
                _tabController.animateTo(index);
              },
              children: [
                Container(),
                Container(),
              ],
            )
          ],) */
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
