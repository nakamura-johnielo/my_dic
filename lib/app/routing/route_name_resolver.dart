import 'package:my_dic/core/shared/enums/entry_point.dart';
import 'package:my_dic/router/route_names.dart';

/// Resolves the route names nested below each application entry point.
///
/// This is deliberately a pure mapping: callers own the GoRouter invocation
/// and can therefore use the BuildContext that initiated the user action.
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
