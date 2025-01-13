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
  search('検索', Icons.search),
  ranking('頻度別', Icons.assessment);

  const ScreenTab(this.label, this.icon);
  //const ScreenTab(this.label, this.icon,this.root);
  final String label;
  final IconData icon;
  //final root;
}

enum ScreenPage {
  detail('単語詳細');

  const ScreenPage(this.label);
  //const ScreenTab(this.label, this.icon,this.root);
  final String label;
  //final root;
}
