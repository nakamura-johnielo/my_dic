/* class MainScreenTab {
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

// enum MainScreenTab {
//   note('メモ', Icons.note),
//   quiz('Quiz', Icons.handshake),
//   search('検索', Icons.search),
//   ranking('頻度別', Icons.assessment),
//   myword('My Word', Icons.tag_faces),
//   profile('profile', Icons.person);

//   const MainScreenTab(this.label, this.icon);
//   //const MainScreenTab(this.label, this.icon,this.root);
//   final String label;
//   final IconData icon;
//   //final root;
// }

sealed class ScreenBehaivor {
  const ScreenBehaivor(this.label, this.routeName, this.routePath);
  final String label;
  final String routeName;
  final String routePath;
}

sealed class ScreenPageBehaivor extends ScreenBehaivor {
  const ScreenPageBehaivor(super.label, super.routeName, super.routePath);
}

sealed class ScreenTabBehaivor extends ScreenBehaivor {
  const ScreenTabBehaivor(
    super.label,
    this.icon,
    super.routeName,
    super.routePath,
    this.entryPoint,
  );
  final IconData icon;
  final EntryPoint entryPoint;
}

//=======main===========================
class MainScreenTab extends ScreenTabBehaivor {
  const MainScreenTab(super.label, super.icon, super.routeName, super.routePath,
      super.entryPoint);

  static const myword = MainScreenTab(
    'My Word',
    Icons.tag_faces,
    'myword',
    'myword',
    EntryPoint.myword,
  );
  static const search = MainScreenTab(
    '検索',
    Icons.search,
    'search',
    'search',
    EntryPoint.search,
  );
  static const study = MainScreenTab(
    'study',
    Icons.school,
    'study',
    'study',
    EntryPoint.studyRanking,
  );
  // static const profile = MainScreenTab(
  //   'profile',
  //   Icons.person,
  //   'profile',
  //   'profile',
  //   EntryPoint.profile,
  // );
  static const values = [myword, search, study];
}

class MainScreenPage extends ScreenPageBehaivor {
  const MainScreenPage(super.label, super.routeName, super.routePath);

  static const flashCard = MainScreenPage('フラッシュカード', 'flashCard', 'flashCard');
  static const wordDetail = MainScreenPage('単語詳細', 'wordDetail', 'wordDetail');
  static const espJpnDetail =
      MainScreenPage('単語詳細', 'espJpnDetail', 'espJpnDetail');
  static const jpnEspDetail =
      MainScreenPage('単語詳細', 'jpnEspDetail', 'jpnEspDetail');
  // static const unAuthorized =
  //     MainScreenPage('未承認', 'unAuthorized', 'unAuthorized');
  // static const authorized = MainScreenPage('承認済み', 'authorized', 'authorized');
  static const values = [
    flashCard,
    wordDetail,
    espJpnDetail,
    jpnEspDetail,
    // unAuthorized,
    // authorized
  ];
}

//=======study=================================
class StudyScreenTab extends ScreenTabBehaivor {
  const StudyScreenTab(super.label, super.icon, super.routeName,
      super.routePath, super.entryPoint);

  static const dashboard = StudyScreenTab('Dashboard', Icons.dashboard_outlined,
      'dashboard', '/study/dashboard', EntryPoint.studyDashboard);
  static const quiz = StudyScreenTab(
      'Quiz', Icons.handshake, 'quiz', '/study/quiz', EntryPoint.studyQuiz);
  static const ranking = StudyScreenTab(
      '頻度別', Icons.assessment, 'ranking', '/study/ranking', EntryPoint.studyRanking);
  static const values = [dashboard, quiz, ranking];
}

class StudyScreenPage extends ScreenPageBehaivor {
  const StudyScreenPage(super.label, super.routeName, super.routePath);

  static const quizSearch = StudyScreenPage('検索', 'quizSearch', 'quizSearch');
  static const rankCollection =
      StudyScreenPage('ランキング', 'rankCollection', 'rankCollection');
  static const rankSection =
      StudyScreenPage('セクション', 'rankSection', 'rankSection');
  static const values = [quizSearch, rankCollection, rankSection];
}

//=======meta===========================
class MetaScreenTab extends ScreenTabBehaivor {
  const MetaScreenTab(super.label, super.icon, super.routeName, super.routePath,
      super.entryPoint);

  static const profile = MetaScreenTab(
    'profile',
    Icons.person,
    'profile',
    'profile',
    EntryPoint.profile,
  );
  static const values = [profile];
}

class MetaScreenPage extends ScreenPageBehaivor {
  const MetaScreenPage(super.label, super.routeName, super.routePath);

  static const unAuthorized =
      MetaScreenPage('未承認', 'unAuthorized', 'unAuthorized');
  static const authorized = MetaScreenPage('承認済み', 'authorized', 'authorized');

  static const values = [unAuthorized, authorized];
}
