import 'package:my_dic/core/shared/enums/ui/tab.dart';

class RouteNames {
  // Screen Tabs
  static final myWord = MainScreenTab.myword.routeName;
  static final search = MainScreenTab.search.routeName;
  static final study = MainScreenTab.study.routeName;
  static final profile = MetaScreenTab.profile.routeName;

  // Study Sub-routes
  static final dashboard = StudyScreenTab.dashboard.routeName;
  static final ranking = StudyScreenTab.ranking.routeName;
  static final quiz = StudyScreenTab.quiz.routeName;

  static final quizSearch = StudyScreenPage.quizSearch.routeName;
  static final rankCollection = StudyScreenPage.rankCollection.routeName;
  static final rankSection = StudyScreenPage.rankSection.routeName;

  // Shared routes (各ブランチで使う)
  static final wordDetail = MainScreenPage.wordDetail.routeName;
  static final flashCard = MainScreenPage.flashCard.routeName;

  // Auth
  static final unauthorized = MetaScreenPage.unAuthorized.routeName;
  static final authorized = MetaScreenPage.authorized.routeName;
}

class RoutePaths {
  static final myWord = MainScreenTab.myword.routePath;
  static final search = MainScreenTab.search.routePath;
  static final study = MainScreenTab.study.routePath;
  static final profile = MetaScreenTab.profile.routePath;

  static final dashboard = StudyScreenTab.dashboard.routePath;
  static final ranking = StudyScreenTab.ranking.routePath;
  static final quiz = StudyScreenTab.quiz.routePath;
  
  static final quizSearch = StudyScreenPage.quizSearch.routePath;
  static final rankCollection = StudyScreenPage.rankCollection.routePath;
  static final rankSection = StudyScreenPage.rankSection.routePath;

  static final wordDetail = MainScreenPage.wordDetail.routePath;
  static final flashCard = MainScreenPage.flashCard.routePath;

  static final unauthorized = MetaScreenPage.unAuthorized.routePath;
  static final authorized = MetaScreenPage.authorized.routePath;
}
