import 'package:my_dic/app/routing/contracts/route_parse_result.dart';

/// URL-serializable contract for a quiz game.
class QuizGameRoute {
  const QuizGameRoute({required this.wordId, required this.word});

  static const path = 'quiz-game/:wordId';
  static const _wordParameter = 'word';

  final int wordId;
  final String word;

  Map<String, String> get pathParameters => {'wordId': '$wordId'};

  Map<String, String> get queryParameters => {_wordParameter: word};

  static RouteParseResult<QuizGameRoute> parse({
    required Map<String, String> pathParameters,
    required Map<String, String> queryParameters,
  }) {
    final wordId = int.tryParse(pathParameters['wordId'] ?? '');
    final word = queryParameters[_wordParameter];
    if (wordId == null || wordId <= 0) {
      return const RouteParseFailure('wordId must be a positive integer.');
    }
    if (word == null || word.isEmpty) {
      return const RouteParseFailure('word is missing.');
    }
    return RouteParseSuccess(QuizGameRoute(wordId: wordId, word: word));
  }
}
