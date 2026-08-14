import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:my_dic/app/routing/invalid_route_page.dart';
import 'package:my_dic/app/routing/navigation_callbacks.dart';
import 'package:my_dic/app/routing/ranking_presentation_entry.dart';
import 'package:my_dic/app/routing/quiz_presentation_entries.dart';
import 'package:my_dic/app/routing/route_names.dart';
import 'package:my_dic/core/result/route_parse_result.dart';
import 'package:my_dic/features/quiz/port/quiz.dart';
import 'package:my_dic/features/word_detail/port/word_detail.dart';
import 'package:my_dic/app/routing/read_feature_presentation_entries.dart';

final dashboardRoute = GoRoute(
  path: RoutePaths.dashboard,
  name: RouteNames.dashboard,
  pageBuilder: (context, state) => NoTransitionPage(
      key: state.pageKey, child: const Center(child: Text('DASHBOARD'))),
);

final rankingRoute = GoRoute(
  path: RoutePaths.ranking,
  name: RouteNames.ranking,
  pageBuilder: (context, state) => MaterialPage(child: _ranking(context)),
  routes: [
    GoRoute(
      path: RoutePaths.rankCollection,
      name: RouteNames.rankCollection,
      pageBuilder: (context, state) => const MaterialPage(child: Placeholder()),
      routes: [
        GoRoute(
          path: RoutePaths.rankSection,
          name: RouteNames.rankSection,
          pageBuilder: (context, state) =>
              MaterialPage(child: _ranking(context)),
        )
      ],
    )
  ],
);

Widget _ranking(BuildContext context) => RankingPresentationEntry(
      onOpenWordDetail: (word) => openWordDetail(context,
          routeName: '${RouteNames.ranking}-${RouteNames.wordDetail}',
          word: word),
      onOpenQuiz: (word, hint) => openQuizGame(context,
          routeName: '${RouteNames.ranking}-${RouteNames.flashCard}',
          word: word,
          displayHint: hint),
    );

final quizRoute = GoRoute(
  path: RoutePaths.quiz,
  name: RouteNames.quiz,
  pageBuilder: (context, state) => MaterialPage(child: _quizSearch(context)),
  routes: [
    GoRoute(
      path: RoutePaths.quizSearch,
      name: RouteNames.quizSearch,
      pageBuilder: (context, state) =>
          NoTransitionPage(key: state.pageKey, child: _quizSearch(context)),
    )
  ],
);

Widget _quizSearch(BuildContext context) => QuizSearchPresentationEntry(
      onOpenQuiz: (word, hint) => openQuizGame(context,
          routeName: '${RouteNames.quiz}-${RouteNames.flashCard}',
          word: word,
          displayHint: hint),
    );

/// Registers both the canonical Quiz URL and its legacy Esp-Jpn alias.
///
/// The canonical route is named because in-app navigation must always emit the
/// canonical path.  The legacy route is deliberately unnamed and exists only
/// for deep-link/refresh compatibility.
List<GoRoute> flashCardRoutes(String name,
        {String? parentPath, required String wordDetailRouteName}) =>
    [
      flashCardRoute(name,
          parentPath: parentPath, wordDetailRouteName: wordDetailRouteName),
      legacyFlashCardRoute(
          parentPath: parentPath, wordDetailRouteName: wordDetailRouteName),
    ];

GoRoute flashCardRoute(String name,
        {String? parentPath, required String wordDetailRouteName}) =>
    _flashCardRoute(
      path: parentPath == null
          ? QuizGameRoute.path
          : '$parentPath/${QuizGameRoute.path}',
      name: name,
      wordDetailRouteName: wordDetailRouteName,
    );

GoRoute legacyFlashCardRoute(
        {String? parentPath, required String wordDetailRouteName}) =>
    _flashCardRoute(
      path: parentPath == null
          ? QuizGameRoute.legacyPath
          : '$parentPath/${QuizGameRoute.legacyPath}',
      wordDetailRouteName: wordDetailRouteName,
    );

GoRoute _flashCardRoute({
  required String path,
  String? name,
  required String wordDetailRouteName,
}) =>
    GoRoute(
      path: path,
      name: name,
      pageBuilder: (context, state) {
        final result = QuizGameRoute.parse(
            pathParameters: state.pathParameters,
            queryParameters: state.uri.queryParameters);
        return switch (result) {
          RouteParseSuccess(value: final route) => MaterialPage(
              child: QuizGamePresentationEntry(
                  input: QuizGamePresentationInput(
                      word: route.word, displayHint: route.displayHint),
                  onOpenWordDetail: (word) => openWordDetail(context,
                      routeName: wordDetailRouteName, word: word))),
          RouteParseFailure(message: final message) =>
            MaterialPage(child: InvalidRoutePage(message: message)),
        };
      },
    );

GoRoute wordDetailRoute(String name,
        {String? parentPath, required String quizGameRouteName}) =>
    GoRoute(
      path: parentPath == null
          ? WordDetailRoute.path
          : '$parentPath/${WordDetailRoute.path}',
      name: name,
      pageBuilder: (context, state) {
        final result = WordDetailRoute.parse(
            pathParameters: state.pathParameters,
            queryParameters: state.uri.queryParameters);
        return switch (result) {
          RouteParseSuccess(value: final route) => MaterialPage(
              child: WordDetailRouteEntry(
                  input: WordDetailPresentationInput(word: route.word),
                  onOpenQuiz: (word, hint) => openQuizGame(context,
                      routeName: quizGameRouteName,
                      word: word,
                      displayHint: hint))),
          RouteParseFailure(message: final message) =>
            MaterialPage(child: InvalidRoutePage(message: message)),
        };
      },
    );
