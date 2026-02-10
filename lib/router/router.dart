import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:my_dic/features/auth/di/store.dart';
import 'package:my_dic/features/auth/presentation/view/sign_up.dart';
import 'package:my_dic/main_activity.dart';
import 'package:my_dic/features/my_word/presentation/view/my_word_fragment.dart';
import 'package:my_dic/features/search/presentation/view/search_fragment.dart';
import 'package:my_dic/features/user/presentation/view/profile.dart';

import 'package:my_dic/features/auth/domain/entity/app_auth.dart';
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
    ref.listen<AppAuth?>(
      authStoreNotifierProvider,
      (previous, next) {
        if (previous?.isAuthenticated == next?.isAuthenticated &&
            previous?.isLogined == next?.isLogined &&
            previous?.accountId == next?.accountId) {
          print(
              'redirect - [Auth Effect] No change in auth state detected===============================================');
          return;
        }
        print(
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
  final quizKey = ref.watch(quizNavigatorKeyProvider);
  final myWordKey = ref.watch(myWordNavigatorKeyProvider);
  final rankingKey = ref.watch(rankingNavigatorKeyProvider);
  final studyKey = ref.watch(studyNavigatorKeyProvider);
  
  // Study内部用のキーを取得
  final studyDashboardKey = ref.watch(studyDashboardNavigatorKeyProvider);
  final studyRankingKey = ref.watch(studyRankingNavigatorKeyProvider);
  final studyQuizKey = ref.watch(studyQuizNavigatorKeyProvider);
  print("===============routerProvider created======================");

  return GoRouter(
    navigatorKey: rootKey,
    refreshListenable: authNotifier,
    redirect: (context, state) {
      //TODO AUTH変化でbottombarのpathが返ってくる
      final location = state.matchedLocation;
      final uri = state.uri.toString();
      final uri2 = state.uri.path.toString();
      final fullPath = state.fullPath;

      print('========-GoRouter redirect========');
      print('matchedLocation: $location');
      print('uri: $uri');
      print('uri: $uri2');
      print('fullPath: $fullPath');

      // login系のページじゃなければ強勢移動させない
      final inProfile = location.startsWith('/${RoutePaths.profile}');
      if (!inProfile) return null;

      final auth = ref.read(authStoreNotifierProvider);
      final unauthorized = '/${RoutePaths.profile}/${RoutePaths.unauthorized}';
      final authorized = '/${RoutePaths.profile}/${RoutePaths.authorized}';

      if (auth == null) {
        print('auth is null');
        return unauthorized;
      }

      final loggedIn = auth.isLogined;
      final verified = auth.isAuthenticated;
      print('loggedIn: $loggedIn, verified: $verified');

      if (!loggedIn || !verified) {
        print(
            "current location: ${location == unauthorized ? null : unauthorized} ");
        return location == unauthorized ? null : unauthorized;
      }
      print("current location: ${location == authorized ? null : authorized} ");
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
                      RoutePaths.search,
                      "${RouteNames.search}-${RouteNames.flashCard}",
                      searchKey),

                  //word詳細画面
                  wordDetailRoute(
                      RoutePaths.search,
                      "${RouteNames.search}-${RouteNames.wordDetail}",
                      searchKey),
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

              wordDetailRoute(RoutePaths.quiz,
                  "${RouteNames.quiz}-${RouteNames.wordDetail}", studyQuizKey),
              flashCardRoute(RoutePaths.quiz,
                  "${RouteNames.quiz}-${RouteNames.flashCard}", studyQuizKey),
            
            ],
          ),

          // Ranking
          //4
          StatefulShellBranch(
            navigatorKey: studyRankingKey,
            routes: [
              rankingRoute,

              wordDetailRoute(
                  RoutePaths.ranking,
                  "${RouteNames.ranking}-${RouteNames.wordDetail}",
                  studyRankingKey),
              flashCardRoute(
                  RoutePaths.ranking,
                  "${RouteNames.ranking}-${RouteNames.flashCard}",
                  studyRankingKey),
              
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
});

