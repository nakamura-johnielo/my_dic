import 'package:flutter/material.dart';
import 'package:my_dic/_View/dictionary_fragment.dart';

class WordPageFragment extends StatelessWidget {
  const WordPageFragment({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: DefaultTabController(
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
              DictionaryFragment(wordId: 513),
              Icon(Icons.directions_car)
            ],
          ),
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