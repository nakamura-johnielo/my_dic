//word詳細画面
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:my_dic/features/quiz/presentation/view/quiz_game_fragment.dart';
import 'package:my_dic/features/quiz/presentation/view/quiz_search_fragment.dart';
import 'package:my_dic/features/ranking/presentation/view/ranking_fragment.dart';
import 'package:my_dic/router/route_names.dart';
import 'package:my_dic/app/routing/contracts/quiz_game_route.dart';
import 'package:my_dic/app/routing/contracts/route_parse_result.dart';
import 'package:my_dic/app/routing/invalid_route_page.dart';

//=========dashboard=========================
final dashboardRoute = GoRoute(
  path: RoutePaths.dashboard,
  name: RouteNames.dashboard,
  pageBuilder: (context, state) {
    return NoTransitionPage(
      key: state.pageKey,
      child: Center(
        child: Text("DASHBOARD"),
      ),
    );
  },
);

// ===========ranking============================
final rankingRoute = GoRoute(
    path: RoutePaths.ranking,
    name: RouteNames.ranking,
    //TODO implement
    pageBuilder: (context, state) {
      return MaterialPage(child: RankingFragment());
    },
    routes: [
      //level一覧
      GoRoute(
        path: RoutePaths.rankCollection,
        name: RouteNames.rankCollection,
        //TODO implement
        pageBuilder: (context, state) {
          return MaterialPage(child: Placeholder());
        },
        routes: [
          // level画面
          // word一覧
          GoRoute(
            path: RoutePaths.rankSection,
            name: RouteNames.rankSection,
            pageBuilder: (context, state) {
              return MaterialPage(child: RankingFragment());
            },
          ),
        ],
      ),
    ]);

//========quiz========================
final quizRoute = GoRoute(
    //TODO 修正
    path: RoutePaths.quiz,
    name: RouteNames.quiz,
    //TODO implement
    pageBuilder: (context, state) {
      return MaterialPage(child: QuizSearchFragment());
    },
    routes: [
      //search & home
      GoRoute(
        path: RoutePaths.quizSearch,
        name: RouteNames.quizSearch,
        pageBuilder: (context, state) => NoTransitionPage(
          key: state.pageKey,
          child: QuizSearchFragment(),
        ),
      ),
    ]);

GoRoute flashCardRoute(String name, {String? parentPath}) => GoRoute(
      path: parentPath == null
          ? QuizGameRoute.path
          : '$parentPath/${QuizGameRoute.path}',
      name: name,
      pageBuilder: (context, state) {
        final result = QuizGameRoute.parse(
          pathParameters: state.pathParameters,
          queryParameters: state.uri.queryParameters,
        );
        return switch (result) {
          RouteParseSuccess(value: final route) =>
            MaterialPage(child: QuizGameFragment(route: route)),
          RouteParseFailure(message: final message) =>
            MaterialPage(child: InvalidRoutePage(message: message)),
        };
      },
    );
