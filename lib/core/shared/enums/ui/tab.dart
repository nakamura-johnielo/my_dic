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
import 'package:my_dic/core/shared/enums/entry_point.dart';

// enum ScreenTab {
//   note('メモ', Icons.note),
//   quiz('Quiz', Icons.handshake),
//   search('検索', Icons.search),
//   ranking('頻度別', Icons.assessment),
//   myword('My Word', Icons.tag_faces),
//   profile('profile', Icons.person);

//   const ScreenTab(this.label, this.icon);
//   //const ScreenTab(this.label, this.icon,this.root);
//   final String label;
//   final IconData icon;
//   //final root;
// }

enum ScreenTab {
  // note('メモ', Icons.note),
  // quiz('Quiz', Icons.handshake),
  myword('My Word', Icons.tag_faces, "myword", "myword",EntryPoint.myword),
  search('検索', Icons.search, "search", "search",EntryPoint.search),
  // ranking('頻度別', Icons.assessment),
  study('study', Icons.school, "study", "study",EntryPoint.studyRanking),//TODO study 分ける
  profile('profile', Icons.person, "profile", "profile",EntryPoint.profile);
  const ScreenTab(this.label, this.icon, this.routeName, this.routePath, this.entryPoint);
  //const ScreenTab(this.label, this.icon,this.root);
  final String label;
  final IconData icon;
  final String routeName;
  final String routePath;
  final EntryPoint entryPoint;
  //final root;
}

enum ScreenPage {
  flashCard('フラッシュカード', 'flashCard', 'flashCard'),
  wordDetail('単語詳細', 'wordDetail', 'wordDetail'),

  espJpnDetail('単語詳細', 'espJpnDetail', 'espJpnDetail'),
  jpnEspDetail('単語詳細', 'jpnEspDetail', 'jpnEspDetail'),
  //quizDetail('Quiz!'),
  unAuthorized('未承認', 'unAuthorized', 'unAuthorized'),
  authorized('承認済み', 'authorized', 'authorized');

  const ScreenPage(this.label, this.routeName, this.routePath);
  //const ScreenTab(this.label, this.icon,this.root);
  final String label;
  final String routeName;
  final String routePath;
  //final root;
}

enum StudyScreenTab {
  dashboard('Dashboard', Icons.dashboard_outlined, 'dashboard', 'dashboard'),
  quiz('Quiz', Icons.handshake, 'quiz', 'quiz'),
  ranking('頻度別', Icons.assessment, 'ranking', 'ranking');

  const StudyScreenTab(this.label, this.icon, this.routeName, this.routePath);
  //const ScreenTab(this.label, this.icon,this.root);
  final String label;
  final IconData icon;
  final String routeName;
  final String routePath;
  //final root;
}

enum StudyScreenPage {
  quizSearch('検索', 'quizSearch', 'quizSearch'),
  rankCollection('ランキング', 'rankCollection', 'rankCollection'),
  rankSection('セクション', 'rankSection', 'rankSection');

  const StudyScreenPage(this.label, this.routeName, this.routePath);
  //const ScreenTab(this.label, this.icon,this.root);
  final String label;
  final String routeName;
  final String routePath;
  //final root;
}
