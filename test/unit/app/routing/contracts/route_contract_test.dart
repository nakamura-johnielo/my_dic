import 'package:flutter_test/flutter_test.dart';
import 'package:my_dic/app/routing/contracts/quiz_game_route.dart';
import 'package:my_dic/app/routing/contracts/route_parse_result.dart';
import 'package:my_dic/app/routing/contracts/word_detail_route.dart';
import 'package:my_dic/core/shared/enums/word/word_type.dart';

void main() {
  group('WordDetailRoute', () {
    test('serializes and parses a refresh-safe URL payload', () {
      const route = WordDetailRoute(
        wordId: 42,
        wordType: WordType.espJpn,
        hasConj: true,
      );
      final result = WordDetailRoute.parse(
        pathParameters: route.pathParameters,
        queryParameters: route.queryParameters,
      );

      expect(result, isA<RouteParseSuccess<WordDetailRoute>>());
      expect((result as RouteParseSuccess<WordDetailRoute>).value.wordId, 42);
    });

    test('rejects missing display parameters', () {
      final result = WordDetailRoute.parse(
        pathParameters: const {'wordId': '42'},
        queryParameters: const {},
      );
      expect(result, isA<RouteParseFailure<WordDetailRoute>>());
    });
  });

  test('QuizGameRoute serializes and parses a refresh-safe URL payload', () {
    const route = QuizGameRoute(wordId: 42, word: 'hablar');
    final result = QuizGameRoute.parse(
      pathParameters: route.pathParameters,
      queryParameters: route.queryParameters,
    );

    expect(result, isA<RouteParseSuccess<QuizGameRoute>>());
    expect((result as RouteParseSuccess<QuizGameRoute>).value.word, 'hablar');
  });
}
