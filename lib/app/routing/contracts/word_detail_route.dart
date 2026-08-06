import 'package:my_dic/app/routing/contracts/route_parse_result.dart';
import 'package:my_dic/core/shared/enums/word/word_type.dart';

/// URL-serializable contract for the word detail screen.
///
/// This deliberately contains only plain data and has no Flutter dependency.
class WordDetailRoute {
  const WordDetailRoute({
    required this.wordId,
    required this.wordType,
    required this.hasConj,
  });

  static const path = 'word/:wordId';
  static const _wordTypeParameter = 'type';
  static const _hasConjParameter = 'hasConj';

  final int wordId;
  final WordType wordType;
  final bool hasConj;

  Map<String, String> get pathParameters => {'wordId': '$wordId'};

  Map<String, String> get queryParameters => {
        _wordTypeParameter: wordType.name,
        _hasConjParameter: '$hasConj',
      };

  static RouteParseResult<WordDetailRoute> parse({
    required Map<String, String> pathParameters,
    required Map<String, String> queryParameters,
  }) {
    final wordId = int.tryParse(pathParameters['wordId'] ?? '');
    final wordTypeName = queryParameters[_wordTypeParameter];
    final hasConjName = queryParameters[_hasConjParameter];
    final wordType = WordType.values.where((type) => type.name == wordTypeName);

    if (wordId == null || wordId <= 0) {
      return const RouteParseFailure('wordId must be a positive integer.');
    }
    if (wordType.length != 1) {
      return const RouteParseFailure('type is missing or invalid.');
    }
    if (hasConjName != 'true' && hasConjName != 'false') {
      return const RouteParseFailure('hasConj is missing or invalid.');
    }

    return RouteParseSuccess(WordDetailRoute(
      wordId: wordId,
      wordType: wordType.single,
      hasConj: hasConjName == 'true',
    ));
  }
}
