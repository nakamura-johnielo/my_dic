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
}


/* 
Column(children: [
      MyTabController(),
      DictionaryFragment(wordId: 120),
    ]);
 */