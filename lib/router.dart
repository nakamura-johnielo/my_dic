import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:my_dic/Components/bottom_bar.dart';
import 'package:my_dic/Constants/tab.dart';
import 'package:my_dic/DI/product.dart';
import 'package:my_dic/_View/my_word/my_word_fragment.dart';
import 'package:my_dic/_View/note_fragment.dart';
import 'package:my_dic/_View/quiz/quiz_fragment.dart';
import 'package:my_dic/_View/quiz/quiz_game_fragment.dart';
import 'package:my_dic/_View/ranking/ranking_fragment.dart';
import 'package:my_dic/_View/search/search_fragment.dart';
import 'package:my_dic/_View/word_page/jpn_esp/jpn_esp_word_page_fragment.dart';
import 'package:my_dic/_View/word_page/word_page_fragment.dart';

final rootNavigatorKey = GlobalKey<NavigatorState>();
final searchNavigatorKey = GlobalKey<NavigatorState>(debugLabel: 'search');
// final noteNavigatorKey = GlobalKey<NavigatorState>(debugLabel: 'note');
final quizNavigatorKey = GlobalKey<NavigatorState>(debugLabel: 'quiz');
final myWordNavigatorKey = GlobalKey<NavigatorState>(debugLabel: 'myword');
final rankingNavigatorKey = GlobalKey<NavigatorState>(debugLabel: 'ranking');

final goRouter = GoRouter(
    navigatorKey: rootNavigatorKey,
    //home
    initialLocation: '/${ScreenTab.search}',
    routes: [
      StatefulShellRoute.indexedStack(
          parentNavigatorKey: rootNavigatorKey,
          builder: (context, state, navigationShell) {
            //navbarのデザイン
            return BottomNavBar(navigationShell: navigationShell);
          },
          branches: [
            // mywordブランチ
            StatefulShellBranch(
              navigatorKey: myWordNavigatorKey,
              routes: [
                GoRoute(
                  path: '/${ScreenTab.myword}',
                  pageBuilder: (context, state) => NoTransitionPage(
                    key: state.pageKey,
                    child: DI<MyWordFragment>(),
                  ),
                ),
              ],
            ),

            // noteブランチ
            // StatefulShellBranch(
            //   navigatorKey: noteNavigatorKey,
            //   routes: [
            //     GoRoute(
            //       path: '/${ScreenTab.note}',
            //       pageBuilder: (context, state) => NoTransitionPage(
            //         key: state.pageKey,
            //         child: NoteFragment(),
            //       ),
            //     ),
            //   ],
            // ),

            // quizブランチ
            StatefulShellBranch(
              navigatorKey: quizNavigatorKey,
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
                        parentNavigatorKey: quizNavigatorKey,
                        pageBuilder: (context, state) {
                          final QuizGameFragmentInput input =
                              state.extra as QuizGameFragmentInput;
                          return MaterialPage(
                              child: QuizGameFragment(
                            input: input,
                          ));
                        },
                      ),
                    ]),
              ],
            ),

            // search
            StatefulShellBranch(
              navigatorKey: searchNavigatorKey,
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
                      parentNavigatorKey: searchNavigatorKey,
                      pageBuilder: (context, state) {
                        final WordPageFragmentInput input =
                            state.extra as WordPageFragmentInput;
                        return MaterialPage(
                            child: WordPageFragment(
                          input: input,
                        ));
                      },
                    ),
                    GoRoute(
                      path: '${ScreenPage.jpnEspDetail}',
                      parentNavigatorKey: searchNavigatorKey,
                      pageBuilder: (context, state) {
                        final JpnEspWordPageFragmentInput input =
                            state.extra as JpnEspWordPageFragmentInput;
                        return MaterialPage(
                            child: JpnEspWordPageFragment(
                          input: input,
                        ));
                      },
                    )
                  ],
                ),
              ],
            ),

            /* // detil
            StatefulShellBranch(
              navigatorKey: searchNavigatorKey,
              routes: [
                GoRoute(
                  path: '/${ScreenPage.detail}',
                  parentNavigatorKey: searchNavigatorKey,
                  pageBuilder: (context, state) {
                    final WordPageFragmentInput input =
                        state.extra as WordPageFragmentInput;
                    return MaterialPage(
                        child: WordPageFragment(
                      input: input,
                    ));
                  },
                )
              ],
            ),
 */
            // rankingランチ
            StatefulShellBranch(
              navigatorKey: rankingNavigatorKey,
              routes: [
                GoRoute(
                  path: '/${ScreenTab.ranking}',
                  pageBuilder: (context, state) => NoTransitionPage(
                    key: state.pageKey,
                    child: DI<RankingFragment>(),
                  ),
                  routes: [
                    GoRoute(
                      path: '${ScreenPage.detail}',
                      parentNavigatorKey: rankingNavigatorKey,
                      pageBuilder: (context, state) {
                        final WordPageFragmentInput input =
                            state.extra as WordPageFragmentInput;
                        return MaterialPage(
                            child: WordPageFragment(
                          input: input,
                        ));
                      },
                    )
                  ],
                ),
              ],
            ),
          ]),
    ]);








/* final goRouter = GoRouter(
  // アプリが起動した時
  initialLocation: '/',
  // パスと画面の組み合わせ
  routes: [
    GoRoute(
      path: '/',
      name: 'initial',
      pageBuilder: (context, state) {
        return MaterialPage(
          key: state.pageKey,
          child: SearchFragment(),
        );
      },
    ),
    // ex) アカウント画面
    GoRoute(
      path: '/wordpage',
      name: 'wordpage',
      pageBuilder: (context, state) {
        return MaterialPage(
          key: state.pageKey,
          child: const WordPageFragment(),
        );
      },
    ),
  ],

  // 遷移ページがないなどのエラーが発生した時に、このページに行く
  errorPageBuilder: (context, state) => MaterialPage(
    key: state.pageKey,
    child: Scaffold(
      body: Center(
        child: Text(state.error.toString()),
      ),
    ),
  ),
);
 */