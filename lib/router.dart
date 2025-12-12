import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:my_dic/core/application/app_effects/auth_effect_provider.dart';
import 'package:my_dic/core/domain/entity/auth.dart';
import 'package:my_dic/features/auth/presentation/view/sign_up.dart';
import 'package:my_dic/_View/main_activity.dart';
import 'package:my_dic/Constants/tab.dart';
import 'package:my_dic/_View/my_word/my_word_fragment.dart';
import 'package:my_dic/_View/quiz/quiz_fragment.dart';
import 'package:my_dic/_View/quiz/quiz_game_fragment.dart';
import 'package:my_dic/_View/ranking/ranking_fragment.dart';
import 'package:my_dic/_View/search/search_fragment.dart';
import 'package:my_dic/features/user/presentation/view/profile.dart';
import 'package:my_dic/_View/word_page/jpn_esp/jpn_esp_word_page_fragment.dart';
import 'package:my_dic/_View/word_page/word_page_fragment.dart';

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

class AuthChangeNotifier extends ChangeNotifier {
  AuthChangeNotifier(Ref ref) {
    ref.listen<AsyncValue<AppAuth?>>(
      authStreamProvider,
      (previous, next) {
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
  // final profileKey = ref.watch(profileNavigatorKeyProvider);

  return GoRouter(
    navigatorKey: rootKey,
    refreshListenable: authNotifier,
    redirect: (context, state) {
      final auth = ref.read(authStreamProvider).value;

      final location = state.matchedLocation;
      final uri = state.uri.toString();
      final fullPath = state.fullPath;

      print('========-GoRouter redirect========');
      print('matchedLocation: $location');
      print('uri: $uri');
      print('fullPath: $fullPath');

      final inProfile = location.startsWith('/${ScreenTab.profile}');
      if (!inProfile) return null;

      final loggedIn = auth?.isLogined == true;
      final verified = auth?.isVerified == true;
      final unauthorized = '/${ScreenTab.profile}/${ScreenPage.unAuthorized}';
      final authorized = '/${ScreenTab.profile}/${ScreenPage.authorized}';
      print('loggedIn: $loggedIn, verified: $verified');
      if (!loggedIn || !verified) {
        return location == unauthorized ? null : unauthorized;
      }
      return location == authorized ? null : authorized;
    },
    initialLocation: '/${ScreenTab.search}',
    routes: [
      StatefulShellRoute.indexedStack(
        parentNavigatorKey: rootKey,
        builder: (context, state, navigationShell) {
          return MainActivity(navigationShell: navigationShell);
        },
        branches: [
          StatefulShellBranch(
            navigatorKey: myWordKey,
            routes: [
              GoRoute(
                path: '/${ScreenTab.myword}',
                pageBuilder: (context, state) => NoTransitionPage(
                  key: state.pageKey,
                  child: MyWordFragment(),
                ),
              ),
            ],
          ),
          StatefulShellBranch(
            navigatorKey: quizKey,
            routes: [
              GoRoute(
                path: '/${ScreenTab.quiz}',
                pageBuilder: (context, state) => NoTransitionPage(
                  key: state.pageKey,
                  child: QuizFragment(),
                ),
                routes: [
                  GoRoute(
                    path: '${ScreenPage.quizDetail}',
                    parentNavigatorKey: quizKey,
                    pageBuilder: (context, state) {
                      final input = state.extra as QuizGameFragmentInput;
                      return MaterialPage(
                          child: QuizGameFragment(input: input));
                    },
                  ),
                ],
              ),
            ],
          ),
          StatefulShellBranch(
            navigatorKey: searchKey,
            routes: [
              GoRoute(
                path: '/${ScreenTab.search}',
                pageBuilder: (context, state) => NoTransitionPage(
                  key: state.pageKey,
                  child: SearchFragment(),
                ),
                routes: [
                  GoRoute(
                    path: '${ScreenPage.detail}',
                    parentNavigatorKey: searchKey,
                    pageBuilder: (context, state) {
                      final input = state.extra as WordPageFragmentInput;
                      return MaterialPage(
                          child: WordPageFragment(input: input));
                    },
                  ),
                  GoRoute(
                    path: '${ScreenPage.jpnEspDetail}',
                    parentNavigatorKey: searchKey,
                    pageBuilder: (context, state) {
                      final input = state.extra as JpnEspWordPageFragmentInput;
                      return MaterialPage(
                          child: JpnEspWordPageFragment(input: input));
                    },
                  ),
                ],
              ),
            ],
          ),
          StatefulShellBranch(
            navigatorKey: rankingKey,
            routes: [
              GoRoute(
                path: '/${ScreenTab.ranking}',
                pageBuilder: (context, state) => NoTransitionPage(
                  key: state.pageKey,
                  child: RankingFragment(),
                ),
                routes: [
                  GoRoute(
                    path: '${ScreenPage.detail}',
                    parentNavigatorKey: rankingKey,
                    pageBuilder: (context, state) {
                      final input = state.extra as WordPageFragmentInput;
                      return MaterialPage(
                          child: WordPageFragment(input: input));
                    },
                  ),
                ],
              ),
            ],
          ),

          // StatefulShellBranch(
          //   navigatorKey: profileKey,
          //   routes: [
          //     GoRoute(
          //       path: '/${ScreenTab.profile}',
          //       pageBuilder: (context, state) => NoTransitionPage(
          //         key: state.pageKey,
          //         child: EmailPasswordPage(),
          //       ),
          //       routes: [
          //         GoRoute(
          //           path: '${ScreenPage.unAuthorized}',
          //           parentNavigatorKey: profileKey,
          //           pageBuilder: (context, state) {
          //             return MaterialPage(child: EmailPasswordPage());
          //           },
          //         ),
          //         GoRoute(
          //           path: '${ScreenPage.authorized}',
          //           parentNavigatorKey: profileKey,
          //           pageBuilder: (context, state) {
          //             //final uid = state.extra as String;
          //             return MaterialPage(child: ProfilePage(uid: "uid"));
          //           },
          //         ),
          //       ],
          //     ),
          //   ],
          // ),
        ],
      ),
      GoRoute(
        parentNavigatorKey: rootKey,
        path: '/${ScreenTab.profile}',
        pageBuilder: (context, state) => NoTransitionPage(
          key: state.pageKey,
          child: EmailPasswordPage(),
        ),
        routes: [
          GoRoute(
            parentNavigatorKey: rootKey,
            path: '${ScreenPage.unAuthorized}',
            //parentNavigatorKey: profileKey,
            pageBuilder: (context, state) {
              return MaterialPage(child: EmailPasswordPage());
            },
          ),
          GoRoute(
            path: '${ScreenPage.authorized}',
            parentNavigatorKey: rootKey,
            pageBuilder: (context, state) {
              //final uid = state.extra as String;
              return MaterialPage(child: ProfilePage(uid: "uid"));
            },
          ),
        ],
      ),
    ],
  );
});



// final goRouter = GoRouter(
//     navigatorKey: rootNavigatorKey,
//     //home
//     initialLocation: '/${ScreenTab.search}',
//     routes: [
//       StatefulShellRoute.indexedStack(
//           parentNavigatorKey: rootNavigatorKey,
//           builder: (context, state, navigationShell) {
//             //navbarのデザイン
//             return MainActivity(navigationShell: navigationShell);
//           },
//           branches: [
//             // mywordブランチ
//             StatefulShellBranch(
//               navigatorKey: myWordNavigatorKey,
//               routes: [
//                 GoRoute(
//                   path: '/${ScreenTab.myword}',
//                   pageBuilder: (context, state) => NoTransitionPage(
//                     key: state.pageKey,
//                     child: DI<MyWordFragment>(),
//                   ),
//                 ),
//               ],
//             ),

//             // noteブランチ
//             // StatefulShellBranch(
//             //   navigatorKey: noteNavigatorKey,
//             //   routes: [
//             //     GoRoute(
//             //       path: '/${ScreenTab.note}',
//             //       pageBuilder: (context, state) => NoTransitionPage(
//             //         key: state.pageKey,
//             //         child: NoteFragment(),
//             //       ),
//             //     ),
//             //   ],
//             // ),

//             // quizブランチ
//             StatefulShellBranch(
//               navigatorKey: quizNavigatorKey,
//               routes: [
//                 GoRoute(
//                     path: '/${ScreenTab.quiz}',
//                     pageBuilder: (context, state) => NoTransitionPage(
//                           key: state.pageKey,
//                           child: QuizFragment(),
//                         ),
//                     routes: [
//                       GoRoute(
//                         path: '${ScreenPage.quizDetail}',
//                         parentNavigatorKey: quizNavigatorKey,
//                         pageBuilder: (context, state) {
//                           final QuizGameFragmentInput input =
//                               state.extra as QuizGameFragmentInput;
//                           return MaterialPage(
//                               child: QuizGameFragment(
//                             input: input,
//                           ));
//                         },
//                       ),
//                     ]),
//               ],
//             ),

//             // search
//             StatefulShellBranch(
//               navigatorKey: searchNavigatorKey,
//               routes: [
//                 GoRoute(
//                   path: '/${ScreenTab.search}',
//                   pageBuilder: (context, state) => NoTransitionPage(
//                     key: state.pageKey,
//                     child: SearchFragment(),
//                   ),
//                   routes: [
//                     GoRoute(
//                       path: '${ScreenPage.detail}',
//                       parentNavigatorKey: searchNavigatorKey,
//                       pageBuilder: (context, state) {
//                         final WordPageFragmentInput input =
//                             state.extra as WordPageFragmentInput;
//                         return MaterialPage(
//                             child: WordPageFragment(
//                           input: input,
//                         ));
//                       },
//                     ),
//                     GoRoute(
//                       path: '${ScreenPage.jpnEspDetail}',
//                       parentNavigatorKey: searchNavigatorKey,
//                       pageBuilder: (context, state) {
//                         final JpnEspWordPageFragmentInput input =
//                             state.extra as JpnEspWordPageFragmentInput;
//                         return MaterialPage(
//                             child: JpnEspWordPageFragment(
//                           input: input,
//                         ));
//                       },
//                     )
//                   ],
//                 ),
//               ],
//             ),

//             /* // detil
//             StatefulShellBranch(
//               navigatorKey: searchNavigatorKey,
//               routes: [
//                 GoRoute(
//                   path: '/${ScreenPage.detail}',
//                   parentNavigatorKey: searchNavigatorKey,
//                   pageBuilder: (context, state) {
//                     final WordPageFragmentInput input =
//                         state.extra as WordPageFragmentInput;
//                     return MaterialPage(
//                         child: WordPageFragment(
//                       input: input,
//                     ));
//                   },
//                 )
//               ],
//             ),
//  */
//             // rankingランチ
//             StatefulShellBranch(
//               navigatorKey: rankingNavigatorKey,
//               routes: [
//                 GoRoute(
//                   path: '/${ScreenTab.ranking}',
//                   pageBuilder: (context, state) => NoTransitionPage(
//                     key: state.pageKey,
//                     child: DI<RankingFragment>(),
//                   ),
//                   routes: [
//                     GoRoute(
//                       path: '${ScreenPage.detail}',
//                       parentNavigatorKey: rankingNavigatorKey,
//                       pageBuilder: (context, state) {
//                         final WordPageFragmentInput input =
//                             state.extra as WordPageFragmentInput;
//                         return MaterialPage(
//                             child: WordPageFragment(
//                           input: input,
//                         ));
//                       },
//                     )
//                   ],
//                 ),
//               ],
//             ),

//             // signUpブランチ
//             StatefulShellBranch(
//               navigatorKey: profileNavigatorKey,
//               routes: [
//                 GoRoute(
//                     path: '/${ScreenTab.profile}',
//                     pageBuilder: (context, state) => NoTransitionPage(
//                           key: state.pageKey,
//                           child: EmailPasswordPage(),
//                         ),
//                     routes: [
//                       GoRoute(
//                         path: '${ScreenPage.unAuthorized}',
//                         parentNavigatorKey: profileNavigatorKey,
//                         pageBuilder: (context, state) {
//                           //final String uid = state.extra as String;
//                           return MaterialPage(child: EmailPasswordPage());
//                         },
//                       ),
//                       GoRoute(
//                         path: '${ScreenPage.authorized}',
//                         parentNavigatorKey: profileNavigatorKey,
//                         pageBuilder: (context, state) {
//                           final String uid = state.extra as String;
//                           return MaterialPage(
//                             child: ProfilePage(
//                               uid: uid,
//                             ),
//                           );
//                         },
//                       )
//                     ]),
//               ],
//             ),
//           ]),
//     ]);







