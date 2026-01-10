import 'package:my_dic/core/shared/enums/ui/tab.dart';

class RouteNames {
  // Screen Tabs
  static final myWord = ScreenTab.myword.routeName;
  static final search = ScreenTab.search.routeName;
  static final study = ScreenTab.study.routeName;
  static final profile = ScreenTab.profile.routeName;

  // Study Sub-routes
  static final dashboard = StudyScreenTab.dashboard.routeName;
  static final ranking = StudyScreenTab.ranking.routeName;
  static final quiz = StudyScreenTab.quiz.routeName;

  static final quizSearch = StudyScreenPage.quizSearch.routeName;
  static final rankCollection = StudyScreenPage.rankCollection.routeName;
  static final rankSection = StudyScreenPage.rankSection.routeName;

  // Shared routes (各ブランチで使う)
  static final wordDetail = ScreenPage.wordDetail.routeName;
  static final flashCard = ScreenPage.flashCard.routeName;

  // Auth
  static final unauthorized = ScreenPage.unAuthorized.routeName;
  static final authorized = ScreenPage.authorized.routeName;
}

class RoutePaths {
  static final myWord = ScreenTab.myword.routePath;
  static final search = ScreenTab.search.routePath;
  static final study = ScreenTab.study.routePath;
  static final profile = ScreenTab.profile.routePath;

  static final dashboard = StudyScreenTab.dashboard.routePath;
  static final ranking = StudyScreenTab.ranking.routePath;
  static final quiz = StudyScreenTab.quiz.routePath;
  
  static final quizSearch = StudyScreenPage.quizSearch.routePath;
  static final rankCollection = StudyScreenPage.rankCollection.routePath;
  static final rankSection = StudyScreenPage.rankSection.routePath;

  static final wordDetail = ScreenPage.wordDetail.routePath;
  static final flashCard = ScreenPage.flashCard.routePath;

  static final unauthorized = ScreenPage.unAuthorized.routePath;
  static final authorized = ScreenPage.authorized.routePath;
}
