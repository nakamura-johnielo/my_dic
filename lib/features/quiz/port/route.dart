import 'package:my_dic/core/result/route_parse_result.dart';
import 'package:my_dic/features/catalog/port/catalog_id.dart';
import 'package:my_dic/features/catalog/port/catalog_word_ref.dart';

/// URL-serializable route contract for a Quiz game.
///
/// [word] is the sole identity. [displayHint] is optional presentation data and
/// never participates in identity or route parsing.
final class QuizGameRoute {
  const QuizGameRoute({required this.word, this.displayHint});

  static const path = 'quiz-game/:wordId';
  static const _catalogParameter = 'catalog';
  static const _displayHintParameter = 'word';

  final CatalogWordRef word;
  final String? displayHint;

  Map<String, String> get pathParameters => {'wordId': '${word.wordId}'};

  Map<String, String> get queryParameters => {
        _catalogParameter: word.catalogId.wireValue,
        if (displayHint case final hint? when hint.isNotEmpty)
          _displayHintParameter: hint,
      };

  static RouteParseResult<QuizGameRoute> parse({
    required Map<String, String> pathParameters,
    required Map<String, String> queryParameters,
  }) {
    final wordId = int.tryParse(pathParameters['wordId'] ?? '');
    if (wordId == null || wordId <= 0) {
      return const RouteParseFailure('wordId must be a positive integer.');
    }
    final catalogId = CatalogId.tryParse(queryParameters[_catalogParameter] ?? '');
    if (catalogId == null) {
      return const RouteParseFailure('catalog is missing or invalid.');
    }
    return RouteParseSuccess(QuizGameRoute(
      word: CatalogWordRef(catalogId: catalogId, wordId: wordId),
      displayHint: queryParameters[_displayHintParameter],
    ));
  }
}
