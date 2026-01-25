import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:my_dic/core/application/effects/auth_effect_provider.dart';
import 'package:my_dic/features/auth/di/service.dart';
import 'package:my_dic/features/auth/presentation/view/sign_up.dart';
import 'package:my_dic/main_activity.dart';
import 'package:my_dic/core/shared/consts/ui/tab.dart';
import 'package:my_dic/features/my_word/presentation/view/my_word_fragment.dart';
import 'package:my_dic/features/quiz/presentation/view/quiz_game_fragment.dart';
import 'package:my_dic/features/ranking/presentation/view/ranking_fragment.dart';
import 'package:my_dic/features/quiz/presentation/view/quiz_search_fragment.dart';
import 'package:my_dic/features/search/presentation/view/search_fragment.dart';
import 'package:my_dic/features/user/presentation/view/profile.dart';
import 'package:my_dic/features/word_page/presentation/view/word_page_fragment.dart';

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
      //authStreamProvider,
      (previous, next) {
        if (previous?.isAuthenticated == next?.isAuthenticated) {
          print('redirect - [Auth Effect] No change in auth state detected===============================================');
          return;
        }
        print("redirect -- authchangenotifier==============================================================");
        notifyListeners();
      },
    );
  }
}

// class AuthChangeNotifier extends ChangeNotifier {
//   AuthChangeNotifier(Ref ref) {
//     ref.listen<AsyncValue<AppAuth?>>(
//       authStreamProvider,
//       (previous, next) {
//         if (previous?.value?.isAuthenticated == next.value?.isAuthenticated) {
//           print('[Auth Effect] No change in auth state detected');
//           return;
//         }
//         print("redirect -- authchangenotifier==========================");
//         notifyListeners();
//       },
//     );
//   }
// }

final routerProvider = Provider<GoRouter>((ref) {
  final authNotifier = AuthChangeNotifier(ref);

  // Providerからキーを取得（常に同じインスタンスが返される）
  final rootKey = ref.watch(rootNavigatorKeyProvider);
  final searchKey = ref.watch(searchNavigatorKeyProvider);
  final quizKey = ref.watch(quizNavigatorKeyProvider);
  final myWordKey = ref.watch(myWordNavigatorKeyProvider);
  final rankingKey = ref.watch(rankingNavigatorKeyProvider);
  final studyKey = ref.watch(studyNavigatorKeyProvider);
  // final profileKey = ref.watch(profileNavigatorKeyProvider);
  // Study内部用のキーを取得
  final studyDashboardKey = ref.watch(studyDashboardNavigatorKeyProvider);
  final studyRankingKey = ref.watch(studyRankingNavigatorKeyProvider);
  final studyQuizKey = ref.watch(studyQuizNavigatorKeyProvider);

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
      if (location == null) return null;

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

          // Quiz
          // StatefulShellBranch(
          //   navigatorKey: quizKey,
          //   routes: [
          //     GoRoute(
          //       path: '/${MainScreenTab.quiz}',
          //       pageBuilder: (context, state) => NoTransitionPage(
          //         key: state.pageKey,
          //         child: QuizSearchFragment(),
          //       ),
          //       routes: [
          //         // quiz画面
          //         GoRoute(
          //           path: '${ScreenPage.quizDetail}',
          //           parentNavigatorKey: quizKey,
          //           pageBuilder: (context, state) {
          //             final input = state.extra as QuizGameFragmentInput;
          //             return MaterialPage(
          //                 child: QuizGameFragment(input: input));
          //           },
          //         ),

          //         // word詳細画面
          //         GoRoute(
          //           path: '${ScreenPage.wordDetail}',
          //           parentNavigatorKey: quizKey,
          //           pageBuilder: (context, state) {
          //             final input = state.extra as WordPageInput;
          //             return MaterialPage(
          //                 child: WordPageFragment(input: input));
          //           },
          //         ),
          //       ],
          //     ),
          //   ],
          // ),

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
              // GoRoute(
              //   path: '/${RoutePaths.study}/${RoutePaths.dashboard}',
              //   name: RouteNames.dashboard,
              //   pageBuilder: (context, state) => NoTransitionPage(
              //     key: state.pageKey,
              //     child: Placeholder(), // DashboardFragment()に置き換え
              //   ),
              // ),
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
              // GoRoute(
              //   path: '/${RoutePaths.study}/${RoutePaths.quiz}',
              //   name: RouteNames.quiz,
              //   pageBuilder: (context, state) => NoTransitionPage(
              //     key: state.pageKey,
              //     child: QuizSearchFragment(),
              //   ),
              //   routes: [
              //     GoRoute(
              //       path: RoutePaths.quizSearch,
              //       name: RouteNames.quizSearch,
              //       pageBuilder: (context, state) {
              //         return MaterialPage(child: Placeholder());
              //       },
              //     ),
              //     wordDetailRoute(
              //         "${RouteNames.quiz}-${RouteNames.wordDetail}",
              //         studyQuizKey),
              //     flashCardRoute(
              //         "${RouteNames.quiz}-${RouteNames.flashCard}",
              //         studyQuizKey),
              //   ],
              // ),
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
              // GoRoute(
              //   path: '/${RoutePaths.study}/${RoutePaths.ranking}',
              //   name: RouteNames.ranking,
              //   pageBuilder: (context, state) => NoTransitionPage(
              //     key: state.pageKey,
              //     child: RankingFragment(),
              //   ),
              //   routes: [
              //     GoRoute(
              //       path: RoutePaths.rankCollection,
              //       name: RouteNames.rankCollection,
              //       pageBuilder: (context, state) {
              //         return MaterialPage(child: Placeholder());
              //       },
              //       routes: [
              //         GoRoute(
              //           path: RoutePaths.rankSection,
              //           name: RouteNames.rankSection,
              //           pageBuilder: (context, state) {
              //             return MaterialPage(child: Placeholder());
              //           },
              //         ),
              //       ],
              //     ),
              //     wordDetailRoute(
              //         "${RouteNames.ranking}-${RouteNames.wordDetail}",
              //         studyRankingKey),
              //     flashCardRoute(
              //         "${RouteNames.ranking}-${RouteNames.flashCard}",
              //         studyRankingKey),
              //   ],
              // ),
            ],
          ),

          // Study (ネストしたStatefulShellRoute)
//           StatefulShellBranch(
//             navigatorKey: studyKey,
//             initialLocation:
//                 "${RoutePaths.ranking}/${RoutePaths.rankCollection}/${RoutePaths.rankSection}",
// //
//             routes: [
//               StatefulShellRoute.indexedStack(
//                 parentNavigatorKey: studyKey,
//                 builder: (context, state, navigationShell) {
//                   // Study内のタブ切り替えはStudyActivityで管理
//                   return StudyActivity(navigationShell: navigationShell);
//                 },
//                 branches: [
//                    ],
//               ),
//             ],
//           ),

          // study
//           StatefulShellBranch(
//             navigatorKey: studyKey,
//             initialLocation: "/${RoutePaths.study}/${RoutePaths.ranking}/${RoutePaths.rankCollection}/${RoutePaths.rankSection}",
//             routes: [
//               GoRoute(
//                 path: '/${RoutePaths.study}',
//                 name: RouteNames.study,

//                 //TODO implement
//                 pageBuilder: (context, state) {
//                   return MaterialPage(child: Placeholder());
//                 },
//                 routes: [
//                   // dashboard
//                   dashboardRoute,

//                   // ranking
//                   rankingRoute,

//                   // quiz
//                   quizRoute,
//                   //Study
//                   flashCardRoute(
//                       "${RouteNames.study}-${RouteNames.flashCard}", studyKey),

//                   //word詳細画面
//                   wordDetailRoute(
//                       "${RouteNames.study}-${RouteNames.wordDetail}", studyKey),
//                 ],
//               ),
//             ],
//           ),
// //
          //ranking
          // StatefulShellBranch(
          //   navigatorKey: rankingKey,
          //   routes: [
          //     GoRoute(
          //       path: '/${MainScreenTab.ranking}',
          //       pageBuilder: (context, state) => NoTransitionPage(
          //         key: state.pageKey,
          //         child: RankingFragment(),
          //       ),
          //       routes: [
          //         GoRoute(
          //           path: '${ScreenPage.wordDetail}',
          //           parentNavigatorKey: rankingKey,
          //           pageBuilder: (context, state) {
          //             final input = state.extra as WordPageInput;
          //             return MaterialPage(
          //                 child: WordPageFragment(input: input));
          //           },
          //         ),
          //       ],
          //     ),
          //   ],
          // ),
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
            //parentNavigatorKey: profileKey,
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
              //final uid = state.extra as String;
              return MaterialPage(child: ProfilePage(uid: "uid"));
            },
          ),
        ],
      ),

      // User Profile
       // Singupページ
          // GoRoute(
          //   parentNavigatorKey: rootKey,
          //   path: '/${RoutePaths.profile}/${RoutePaths.unauthorized}',
          //   name: RouteNames.unauthorized,
          //   //parentNavigatorKey: profileKey,
          //   pageBuilder: (context, state) {
          //     return MaterialPage(child: EmailPasswordPage());
          //   },
          // ),

          // // signin済みプロフィールページ
          // GoRoute(
          //   path: '/${RoutePaths.profile}/${RoutePaths.authorized}',
          //   name: RouteNames.authorized,
          //   parentNavigatorKey: rootKey,
          //   pageBuilder: (context, state) {
          //     //final uid = state.extra as String;
          //     return MaterialPage(child: ProfilePage(uid: "uid"));
          //   },
          // ),

      // //Study
      // flashCardRoute(rootKey),

      // //word詳細画面
      // wordDetailRoute(rootKey),
    ],
  );
});



// final goRouter = GoRouter(
//     navigatorKey: rootNavigatorKey,
//     //home
//     initialLocation: '/${MainScreenTab.search}',
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
//                   path: '/${MainScreenTab.myword}',
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
//             //       path: '/${MainScreenTab.note}',
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
//                     path: '/${MainScreenTab.quiz}',
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
//                   path: '/${MainScreenTab.search}',
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
//                   path: '/${MainScreenTab.ranking}',
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
//                     path: '/${MetaScreenTab.profile}',
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







