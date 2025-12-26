/* class ScreenTab {
  static const TabInf note = TabInf("メモ", 0);
  final TabInf search = TabInf("検索", 1);
  final TabInf ranking = TabInf("頻度別", 2);
}

class TabInf {
  final String name;
  final int index;

  TabInf(this.name, this.index);
} */

import 'package:flutter/material.dart';

enum ScreenTab {
  note('メモ', Icons.note),
  quiz('Quiz', Icons.handshake),
  search('検索', Icons.search),
  ranking('頻度別', Icons.assessment),
  myword('My Word', Icons.tag_faces),
  profile('profile', Icons.person);

  const ScreenTab(this.label, this.icon);
  //const ScreenTab(this.label, this.icon,this.root);
  final String label;
  final IconData icon;
  //final root;
}

enum ScreenPage {
  detail('単語詳細'),
  espJpnDetail('単語詳細'),
  jpnEspDetail('単語詳細'),
  quizDetail('Quiz!'),
  unAuthorized('未承認'),
  authorized('承認済み');

  const ScreenPage(this.label);
  //const ScreenTab(this.label, this.icon,this.root);
  final String label;
  //final root;
}
