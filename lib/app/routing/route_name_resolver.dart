import 'package:my_dic/core/shared/enums/entry_point.dart';
import 'package:my_dic/app/routing/route_names.dart';

/// 各アプリケーション入口の配下にネストされたルート名を解決します。
///
/// これは意図的に純粋なマッピングです。呼び出し元がGoRouterの呼び出しを所有するため、
/// ユーザー操作を開始したBuildContextを使用できます。
String routeParentNameFor(EntryPoint entryPoint) => switch (entryPoint) {
      EntryPoint.search => RouteNames.search,
      EntryPoint.studyDashboard => RouteNames.dashboard,
      EntryPoint.studyRanking => RouteNames.ranking,
      EntryPoint.studyQuiz => RouteNames.quiz,
      EntryPoint.myword => RouteNames.myWord,
      EntryPoint.profile => RouteNames.profile,
    };

String wordDetailRouteNameFor(EntryPoint entryPoint) =>
    '${routeParentNameFor(entryPoint)}-${RouteNames.wordDetail}';

String quizGameRouteNameFor(EntryPoint entryPoint) =>
    '${routeParentNameFor(entryPoint)}-${RouteNames.flashCard}';
