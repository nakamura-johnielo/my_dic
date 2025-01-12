import 'package:flutter/material.dart';
import 'package:my_dic/_View/word_page/conjugacion_fragment.dart';
import 'package:my_dic/_View/word_page/dictionary_fragment.dart';

class WordPageFragmentInput {
  final int wordId;
  final bool isVerb;
  WordPageFragmentInput({required this.wordId, required this.isVerb});
}

class WordPageFragment extends StatelessWidget {
  const WordPageFragment({super.key, required this.input});
  final WordPageFragmentInput input;

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
          body: TabBarView(
            //コンテンツ内でpadding,margin調整
            children: [
              DictionaryFragment(wordId: input.wordId),
              ConjugacionFragment(wordId: input.wordId)
            ],
          ),
        ),
      );
    }

    return Scaffold(
      body: DictionaryFragment(wordId: input.wordId),
    );
  }
}


/* 
Column(children: [
      MyTabController(),
      DictionaryFragment(wordId: 120),
    ]);
 */