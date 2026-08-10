import 'package:flutter_test/flutter_test.dart';
import 'package:my_dic/app/routing/route_name_resolver.dart';
import 'package:my_dic/core/shared/enums/entry_point.dart';
import 'package:my_dic/app/routing/route_names.dart';

void main() {
  group('route name resolvers', () {
    test('preserve every entry point route-name prefix', () {
      expect(routeParentNameFor(EntryPoint.search), RouteNames.search);
      expect(
          routeParentNameFor(EntryPoint.studyDashboard), RouteNames.dashboard);
      expect(routeParentNameFor(EntryPoint.studyRanking), RouteNames.ranking);
      expect(routeParentNameFor(EntryPoint.studyQuiz), RouteNames.quiz);
      expect(routeParentNameFor(EntryPoint.myword), RouteNames.myWord);
      expect(routeParentNameFor(EntryPoint.profile), RouteNames.profile);
    });

    test('append the existing detail and quiz route contracts', () {
      expect(
        wordDetailRouteNameFor(EntryPoint.search),
        '${RouteNames.search}-${RouteNames.wordDetail}',
      );
      expect(
        quizGameRouteNameFor(EntryPoint.studyQuiz),
        '${RouteNames.quiz}-${RouteNames.flashCard}',
      );
    });
  });
}
