import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:my_dic/app/routing/navigation_callbacks.dart';
import 'package:my_dic/app/routing/route_definitions.dart';
import 'package:my_dic/app/routing/route_names.dart';
import 'package:my_dic/app/session/app_session.dart';
import 'package:my_dic/app/session/session_providers.dart';
import 'package:my_dic/app/bootstrap/my_word_composition.dart';
import 'package:my_dic/app/bootstrap/session_composition.dart';
import 'package:my_dic/app/routing/auth_lifecycle_presentation_entry.dart';
import 'package:my_dic/app/routing/user_profile_lifecycle_presentation_entry.dart';
import 'package:my_dic/integration/session_lifecycle_workflow/auth_lifecycle_provider.dart';
import 'package:my_dic/core/shared/utils/logger.dart';
import 'package:my_dic/features/my_word/port/presentation_entry.dart';
import 'package:my_dic/features/search/port/presentation_entry.dart';
import 'package:my_dic/main_activity.dart';

final rootNavigatorKeyProvider = Provider<GlobalKey<NavigatorState>>(
    (_) => GlobalKey<NavigatorState>(debugLabel: 'root'));
final searchNavigatorKeyProvider = Provider<GlobalKey<NavigatorState>>(
    (_) => GlobalKey<NavigatorState>(debugLabel: 'search'));
final myWordNavigatorKeyProvider = Provider<GlobalKey<NavigatorState>>(
    (_) => GlobalKey<NavigatorState>(debugLabel: 'myword'));
final studyDashboardNavigatorKeyProvider = Provider<GlobalKey<NavigatorState>>(
    (_) => GlobalKey<NavigatorState>(debugLabel: 'studyDashboard'));
final studyRankingNavigatorKeyProvider = Provider<GlobalKey<NavigatorState>>(
    (_) => GlobalKey<NavigatorState>(debugLabel: 'studyRanking'));
final studyQuizNavigatorKeyProvider = Provider<GlobalKey<NavigatorState>>(
    (_) => GlobalKey<NavigatorState>(debugLabel: 'studyQuiz'));

class AuthChangeNotifier extends ChangeNotifier {
  AuthChangeNotifier(Ref ref) {
    ref.listen<AppSession>(appSessionProvider, (previous, next) {
      if (previous?.runtimeType == next.runtimeType &&
          previous?.accountIdOrNull == next.accountIdOrNull) return;
      notifyListeners();
    });
  }
}

final routerProvider = Provider<GoRouter>((ref) {
  final notifier = AuthChangeNotifier(ref);
  final root = ref.watch(rootNavigatorKeyProvider);
  final search = ref.watch(searchNavigatorKeyProvider);
  final myWord = ref.watch(myWordNavigatorKeyProvider);
  final dashboard = ref.watch(studyDashboardNavigatorKeyProvider);
  final ranking = ref.watch(studyRankingNavigatorKeyProvider);
  final quiz = ref.watch(studyQuizNavigatorKeyProvider);
  final router = GoRouter(
    navigatorKey: root,
    refreshListenable: notifier,
    initialLocation: '/${RoutePaths.search}',
    redirect: (context, state) {
      final location = state.matchedLocation;
      if (!location.startsWith('/${RoutePaths.profile}')) return null;
      final unauthorized = '/${RoutePaths.profile}/${RoutePaths.unauthorized}';
      final authorized = '/${RoutePaths.profile}/${RoutePaths.authorized}';
      return ref.read(appSessionProvider) is AppSessionReady
          ? (location == authorized ? null : authorized)
          : (location == unauthorized ? null : unauthorized);
    },
    routes: [
      StatefulShellRoute.indexedStack(
        parentNavigatorKey: root,
        builder: (context, state, shell) =>
            MainActivity(navigationShell: shell),
        branches: [
          StatefulShellBranch(navigatorKey: myWord, routes: [
            GoRoute(
              path: '/${RoutePaths.myWord}',
              name: RouteNames.myWord,
              pageBuilder: (context, state) {
                final scope = ref.watch(sessionScopeKeyProvider);
                return NoTransitionPage(
                  key: state.pageKey,
                  child: scope == null
                      ? const SizedBox.shrink()
                      : MyWordPresentationPage(
                          scope: scope, ports: ref.watch(myWordPortsProvider)),
                );
              },
            )
          ]),
          StatefulShellBranch(navigatorKey: search, routes: [
            GoRoute(
              path: '/${RoutePaths.search}',
              name: RouteNames.search,
              pageBuilder: (context, state) => NoTransitionPage(
                  key: state.pageKey,
                  child: SearchFragment(
                      onOpenWordDetail: (word) => openWordDetail(context,
                          routeName:
                              '${RouteNames.search}-${RouteNames.wordDetail}',
                          word: word),
                      onOpenQuiz: (word, hint) => openQuizGame(context,
                          routeName:
                              '${RouteNames.search}-${RouteNames.flashCard}',
                          word: word,
                          displayHint: hint))),
              routes: [
                ...flashCardRoutes(
                    '${RouteNames.search}-${RouteNames.flashCard}',
                    wordDetailRouteName:
                        '${RouteNames.search}-${RouteNames.wordDetail}'),
                wordDetailRoute('${RouteNames.search}-${RouteNames.wordDetail}',
                    quizGameRouteName:
                        '${RouteNames.search}-${RouteNames.flashCard}'),
              ],
            )
          ]),
          StatefulShellBranch(
              navigatorKey: dashboard, routes: [dashboardRoute]),
          StatefulShellBranch(navigatorKey: quiz, routes: [
            quizRoute,
            wordDetailRoute('${RouteNames.quiz}-${RouteNames.wordDetail}',
                parentPath: RoutePaths.quiz,
                quizGameRouteName:
                    '${RouteNames.quiz}-${RouteNames.flashCard}'),
            ...flashCardRoutes('${RouteNames.quiz}-${RouteNames.flashCard}',
                parentPath: RoutePaths.quiz,
                wordDetailRouteName:
                    '${RouteNames.quiz}-${RouteNames.wordDetail}'),
          ]),
          StatefulShellBranch(navigatorKey: ranking, routes: [
            rankingRoute,
            wordDetailRoute('${RouteNames.ranking}-${RouteNames.wordDetail}',
                parentPath: RoutePaths.ranking,
                quizGameRouteName:
                    '${RouteNames.ranking}-${RouteNames.flashCard}'),
            ...flashCardRoutes('${RouteNames.ranking}-${RouteNames.flashCard}',
                parentPath: RoutePaths.ranking,
                wordDetailRouteName:
                    '${RouteNames.ranking}-${RouteNames.wordDetail}'),
          ]),
        ],
      ),
      GoRoute(
          parentNavigatorKey: root,
          path: '/${RoutePaths.profile}',
          name: RouteNames.profile,
          pageBuilder: (context, state) => NoTransitionPage(
                key: state.pageKey,
                child: const AuthLifecyclePresentationPage(),
              ),
          routes: [
            GoRoute(
                parentNavigatorKey: root,
                path: RoutePaths.unauthorized,
                name: RouteNames.unauthorized,
                pageBuilder: (context, state) => MaterialPage(
                      child: const AuthLifecyclePresentationPage(),
                    )),
            GoRoute(
                parentNavigatorKey: root,
                path: RoutePaths.authorized,
                name: RouteNames.authorized,
                pageBuilder: (context, state) => MaterialPage(
                      child: UserProfileLifecyclePresentationPage(
                        onSignOut: () =>
                            ref.read(authLifecycleProvider.notifier).signOut(),
                      ),
                    )),
          ]),
    ],
  );
  ref.onDispose(() {
    notifier.dispose();
    router.dispose();
  });
  AppLogger.print('Application router created.');
  return router;
});
