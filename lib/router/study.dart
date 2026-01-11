//word詳細画面
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:my_dic/core/shared/enums/ui/tab.dart';
import 'package:my_dic/features/quiz/presentation/view/quiz_game_fragment.dart';
import 'package:my_dic/features/quiz/presentation/view/quiz_search_fragment.dart';
import 'package:my_dic/features/ranking/presentation/view/ranking_fragment.dart';
import 'package:my_dic/features/word_page/presentation/view/word_page_fragment.dart';
import 'package:my_dic/router/route_names.dart';
import 'package:my_dic/router/word_detail.dart';

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
        // parentNavigatorKey: rootKey,
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
            // parentNavigatorKey: rankingKey,
            pageBuilder: (context, state) {
              return MaterialPage(child: RankingFragment());
            },
            // routes: [
            //   //word詳細画面
            //   wordDetailRoute,

            //   // quiz画面
            //   // flashcard quiz
            //   _flashCardRoute
            // ]
          ),
        ],
      ),
    ]);

//========quiz========================
final quizRoute = GoRoute(//TODO 修正
    path: RoutePaths.quiz,
    name: RouteNames.quiz,
    //TODO implement
    pageBuilder: (context, state) {
      return MaterialPage(child: QuizSearchFragment());
    },
    routes: [
      //search & home
      GoRoute(
        // parentNavigatorKey: rootKey,
        path: RoutePaths.quizSearch,
        name: RouteNames.quizSearch,
        pageBuilder: (context, state) => NoTransitionPage(
          key: state.pageKey,
          child: QuizSearchFragment(),
        ),
        // routes: [
        //   // flashcard quiz
        //   _flashCardRoute,
        // ],
      ),
    ]);

GoRoute flashCardRoute(String parentPath, String name,GlobalKey<NavigatorState>? key) => GoRoute(
      path: "$parentPath/${RoutePaths.flashCard}",
      name: name,
      //parentNavigatorKey: key,
      pageBuilder: (context, state) {
        final input = state.extra as QuizGameFragmentInput;
        return MaterialPage(child: QuizGameFragment(input: input));
      },
      // routes: [
      //   //word詳細画面
      //   wordDetailRoute
      // ]
    );
