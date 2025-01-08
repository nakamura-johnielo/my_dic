import 'package:flutter/material.dart';
import 'package:my_dic/_View/conjugacion_fragment.dart';
import 'package:my_dic/_View/dictionary_fragment.dart';

class WordPageFragment extends StatelessWidget {
  const WordPageFragment({super.key, required this.wordId});
  final int wordId;

  @override
  Widget build(BuildContext context) {
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
            DictionaryFragment(wordId: wordId),
            ConjugacionFragment(wordId: wordId)
          ],
        ),
      ),
    );
  }
}


/* 
Column(children: [
      MyTabController(),
      DictionaryFragment(wordId: 120),
    ]);
 */