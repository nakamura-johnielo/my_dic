import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:my_dic/core/application/auth_lifecycle/auth_lifecycle_provider.dart';
import 'package:my_dic/core/application/auth_lifecycle/auth_lifecycle_state.dart';
import 'package:my_dic/features/auth/presentation/view/sign_up.dart';
import 'package:my_dic/main_activity.dart';
import 'package:my_dic/features/my_word/presentation/view/my_word_fragment.dart';
import 'package:my_dic/features/search/presentation/view/search_fragment.dart';
import 'package:my_dic/features/user/presentation/view/profile.dart';
import 'package:my_dic/core/shared/utils/logger.dart';

import 'package:my_dic/router/route_names.dart';
import 'package:my_dic/router/study.dart';
import 'package:my_dic/router/word_detail.dart';

// GlobalKeyをProvider内で作成して使い回す
final rootNavigatorKeyProvider = Provider<GlobalKey<NavigatorState>>((ref) {
  return GlobalKey<NavigatorState>(debugLabel: 'root');
});

final searchNavigatorKeyProvider = Provider<GlobalKey<NavigatorState>>((ref) {
  return GlobalKey<NavigatorState>(debugLabel: 'search');
});

final quizNavigatorKeyProvider = Provider<GlobalKey<NavigatorState>>((ref) {
  return GlobalKey<NavigatorState>(debugLabel: 'quiz');
});

final myWordNavigatorKeyProvider = Provider<GlobalKey<NavigatorState>>((ref) {
  return GlobalKey<NavigatorState>(debugLabel: 'myword');
});

final rankingNavigatorKeyProvider = Provider<GlobalKey<NavigatorState>>((ref) {
  return GlobalKey<NavigatorState>(debugLabel: 'ranking');
});

final profileNavigatorKeyProvider = Provider<GlobalKey<NavigatorState>>((ref) {
  return GlobalKey<NavigatorState>(debugLabel: 'profile');
});

final studyNavigatorKeyProvider = Provider<GlobalKey<NavigatorState>>((ref) {
  return GlobalKey<NavigatorState>(debugLabel: 'study');
});

// Study用のNavigatorKeyを追加
final studyDashboardNavigatorKeyProvider =
    Provider<GlobalKey<NavigatorState>>((ref) {
  return GlobalKey<NavigatorState>(debugLabel: 'studyDashboard');
});

final studyRankingNavigatorKeyProvider =
    Provider<GlobalKey<NavigatorState>>((ref) {
  return GlobalKey<NavigatorState>(debugLabel: 'studyRanking');
});

final studyQuizNavigatorKeyProvider =
    Provider<GlobalKey<NavigatorState>>((ref) {
  return GlobalKey<NavigatorState>(debugLabel: 'studyQuiz');
});

class AuthChangeNotifier extends ChangeNotifier {
  AuthChangeNotifier(Ref ref) {
    ref.listen<AuthLifecycleState>(
      authLifecycleProvider,
      (previous, next) {
        if (previous?.phase == next.phase &&
            previous?.auth?.accountId == next.auth?.accountId) {
          AppLogger.print(
              'redirect - [Auth Effect] No change in auth state detected===============================================');
          return;
        }
        AppLogger.print(
            "redirect -- authchangenotifier==============================================================");
        notifyListeners();
      },
    );
  }
}

final routerProvider = Provider<GoRouter>((ref) {
  final authNotifier = AuthChangeNotifier(ref);

  // Providerからキーを取得（常に同じインスタンスが返される）
  final rootKey = ref.watch(rootNavigatorKeyProvider);
  final searchKey = ref.watch(searchNavigatorKeyProvider);
  final myWordKey = ref.watch(myWordNavigatorKeyProvider);

  // Study内部用のキーを取得
  final studyDashboardKey = ref.watch(studyDashboardNavigatorKeyProvider);
  final studyRankingKey = ref.watch(studyRankingNavigatorKeyProvider);
  final studyQuizKey = ref.watch(studyQuizNavigatorKeyProvider);
  AppLogger.print(
      "===============routerProvider created======================");

  final router = GoRouter(
    navigatorKey: rootKey,
    refreshListenable: authNotifier,
    redirect: (context, state) {
      //TODO AUTH変化でbottombarのpathが返ってくる
      final location = state.matchedLocation;
      final uri = state.uri.toString();
      final uri2 = state.uri.path.toString();
      final fullPath = state.fullPath;

      AppLogger.print('========-GoRouter redirect========');
      AppLogger.print('matchedLocation: $location');
      AppLogger.print('uri: $uri');
      AppLogger.print('uri: $uri2');
      AppLogger.print('fullPath: $fullPath');

      // login系のページじゃなければ強勢移動させない
      final inProfile = location.startsWith('/${RoutePaths.profile}');
      if (!inProfile) return null;

      final lifecycle = ref.read(authLifecycleProvider);
      final unauthorized = '/${RoutePaths.profile}/${RoutePaths.unauthorized}';
      final authorized = '/${RoutePaths.profile}/${RoutePaths.authorized}';

      if (!lifecycle.isReady) {
        AppLogger.print(
            "current location: ${location == unauthorized ? null : unauthorized} ");
        return location == unauthorized ? null : unauthorized;
      }
      AppLogger.print(
          "current location: ${location == authorized ? null : authorized} ");
      return location == authorized ? null : authorized;
    },
    initialLocation: '/${RoutePaths.search}',
    routes: [
      //mainnavbar
      StatefulShellRoute.indexedStack(
        parentNavigatorKey: rootKey,
        builder: (context, state, navigationShell) {
          return MainActivity(navigationShell: navigationShell);
        },
        branches: [
          // My word
          //0
          StatefulShellBranch(
            navigatorKey: myWordKey,
            routes: [
              GoRoute(
                path: '/${RoutePaths.myWord}',
                name: RouteNames.myWord,
                pageBuilder: (context, state) => NoTransitionPage(
                  key: state.pageKey,
                  child: MyWordFragment(),
                ),
              ),
            ],
          ),

          // Search
          //1
          StatefulShellBranch(
            navigatorKey: searchKey,
            routes: [
              GoRoute(
                path: '/${RoutePaths.search}',
                name: RouteNames.search,
                pageBuilder: (context, state) => NoTransitionPage(
                  key: state.pageKey,
                  child: SearchFragment(),
                ),
                routes: [
                  //Study
                  flashCardRoute(
                      "${RouteNames.search}-${RouteNames.flashCard}"),

                  //word詳細画面
                  wordDetailRoute(
                      "${RouteNames.search}-${RouteNames.wordDetail}"),
                ],
              ),
            ],
          ),

          // DashboardF
          //2
          StatefulShellBranch(
            navigatorKey: studyDashboardKey,
            routes: [
              // dashboard
              dashboardRoute,
            ],
          ),

          // Quiz
          //3
          StatefulShellBranch(
            navigatorKey: studyQuizKey,
            routes: [
              // quiz
              quizRoute,

              wordDetailRoute("${RouteNames.quiz}-${RouteNames.wordDetail}",
                  parentPath: RoutePaths.quiz),
              flashCardRoute("${RouteNames.quiz}-${RouteNames.flashCard}",
                  parentPath: RoutePaths.quiz),
            ],
          ),

          // Ranking
          //4
          StatefulShellBranch(
            navigatorKey: studyRankingKey,
            routes: [
              rankingRoute,
              wordDetailRoute("${RouteNames.ranking}-${RouteNames.wordDetail}",
                  parentPath: RoutePaths.ranking),
              flashCardRoute("${RouteNames.ranking}-${RouteNames.flashCard}",
                  parentPath: RoutePaths.ranking),
            ],
          ),
        ],
      ),

      // User Profile
      GoRoute(
        parentNavigatorKey: rootKey,
        path: '/${RoutePaths.profile}',
        name: RouteNames.profile,
        pageBuilder: (context, state) => NoTransitionPage(
          key: state.pageKey,
          child: EmailPasswordPage(),
        ),
        routes: [
          // Singupページ
          GoRoute(
            parentNavigatorKey: rootKey,
            path: RoutePaths.unauthorized,
            name: RouteNames.unauthorized,
            pageBuilder: (context, state) {
              return MaterialPage(child: EmailPasswordPage());
            },
          ),

          // signin済みプロフィールページ
          GoRoute(
            path: RoutePaths.authorized,
            name: RouteNames.authorized,
            parentNavigatorKey: rootKey,
            pageBuilder: (context, state) {
              return MaterialPage(child: ProfilePage(uid: "uid"));
            },
          ),
        ],
      ),
    ],
  );

  ref.onDispose(() {
    authNotifier.dispose();
    router.dispose();
  });

  return router;
});
