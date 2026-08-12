import 'package:flutter/widgets.dart';
import 'package:go_router/go_router.dart';
import 'package:my_dic/features/catalog/port/catalog.dart';
import 'package:my_dic/features/quiz/port/route.dart';
import 'package:my_dic/features/word_detail/port/route.dart';

void openWordDetail(
  BuildContext context, {
  required String routeName,
  required CatalogWordRef word,
}) {
  final route = WordDetailRoute(word: word);
  context.pushNamed(routeName,
      pathParameters: route.pathParameters,
      queryParameters: route.queryParameters);
}

void openQuizGame(
  BuildContext context, {
  required String routeName,
  required CatalogWordRef word,
  String? displayHint,
}) {
  final route = QuizGameRoute(word: word, displayHint: displayHint);
  context.pushNamed(routeName,
      pathParameters: route.pathParameters,
      queryParameters: route.queryParameters);
}
