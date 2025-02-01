import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:my_dic/DI/product.dart';
import 'package:my_dic/_View/word_page/conjugacion_fragment.dart';
import 'package:my_dic/_View/word_page/dictionary_fragment.dart';
import 'package:my_dic/utils/random.dart';
import 'package:tuple/tuple.dart';

class WordPageFragmentInput {
  final int wordId;
  final bool isVerb;
  WordPageFragmentInput({required this.wordId, required this.isVerb});
}

class WordPageFragment extends StatefulWidget {
  const WordPageFragment({super.key, required this.input});
  final WordPageFragmentInput input;

  @override
  State<WordPageFragment> createState() => _WordPageFragmentState();
}

class _WordPageFragmentState extends State<WordPageFragment>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  late WordPageFragmentInput input;
  final PageStorageBucket _bucket = PageStorageBucket();

  @override
  void initState() {
    super.initState();
    if (widget.input.isVerb) {
      _tabController = TabController(length: 2, vsync: this);
    }
    input = widget.input;
    _tabController.addListener(_tabListener);
  }

  // リスナーを定義
  void _tabListener() {
    setState(() {
      // インデックス変更時にウィジェットを再ビルド
    });
  }

  @override
  void dispose() {
    _tabController.removeListener(_tabListener);
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (input.isVerb) {
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
          child: //TabBarView(
              IndexedStack(
            index: _tabController.index,
            //コンテンツ内でpadding,margin調整
            //controller: _tabController,
            children: [
              DI<DictionaryFragment>(
                  param1: WordPageChildInputData(
                      wordId: input.wordId,
                      key: PageStorageKey(generateUUID()))),
              DI<ConjugacionFragment>(
                  param1: WordPageChildInputData(
                      wordId: input.wordId,
                      key: PageStorageKey(generateUUID()))),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      body: DI<DictionaryFragment>(
          param1: WordPageChildInputData(
              wordId: input.wordId, key: PageStorageKey(generateUUID()))),
    );
  }
}

/* 
class WordPageFragment extends StatelessWidget {
  const WordPageFragment({super.key, required this.input});
  final WordPageFragmentInput input;
  static final PageStorageBucket _bucket = PageStorageBucket();

  @override
  Widget build(BuildContext context) {
    if (input.isVerb) {
      return DefaultTabController(
        length: 2,
        child: Scaffold(
          appBar: PreferredSize(
            preferredSize: Size.fromHeight(kToolbarHeight),
            child: TabBar(
              tabs: [
                Tab(text: 'Dictionary'),
                Tab(text: 'Conjugacion'),
              ],
            ),
          ),
          body: PageStorage(
            bucket: _bucket,
            child: TabBarView(
              //コンテンツ内でpadding,margin調整
              children: [
                DI<DictionaryFragment>(
                    param1:
                        Tuple2(input.wordId, PageStorageKey(generateUUID()))),
                DI<ConjugacionFragment>(
                    param1:
                        Tuple2(input.wordId, PageStorageKey(generateUUID()))),
              ],
            ),
          ),
        ),
      );
    }

    return Scaffold(
      body: DI<DictionaryFragment>(
          param1: Tuple2(input.wordId, PageStorageKey(generateUUID()))),
    );
  }
} */


/* 
Column(children: [
      MyTabController(),
      DictionaryFragment(wordId: 120),
    ]);
 */