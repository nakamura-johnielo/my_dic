import 'package:my_dic/core/result/route_parse_result.dart';
import 'package:my_dic/features/catalog/port/catalog.dart';

/// Quiz ゲーム用の URL シリアライズ可能なルート契約。
///
/// [word] が唯一の識別子である。[displayHint] は任意の表示データであり、識別や
/// ルート解析には決して関与しない。
final class QuizGameRoute {
  const QuizGameRoute({required this.word, this.displayHint});

  /// 正規化済みで、リフレッシュしても安全な Quiz URL。
  static const path = 'quiz-game/:catalog/:wordId';

  /// 互換性維持期間中に受け入れる以前の URL。データセットは明確に元の Esp-Jpn
  /// カタログである。
  static const legacyPath = 'quiz-game/:wordId';

  static const _catalogParameter = 'catalog';
  static const _displayHintParameter = 'word';

  final CatalogWordRef word;
  final String? displayHint;

  Map<String, String> get pathParameters => {
        _catalogParameter: word.catalogId.wireValue,
        'wordId': '${word.wordId}',
      };

  Map<String, String> get queryParameters => {
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
    final catalog = pathParameters[_catalogParameter];
    final catalogId = switch (catalog) {
      null => CatalogId.espJpnMain,
      _ => CatalogId.tryParse(catalog),
    };
    if (catalogId == null) {
      return const RouteParseFailure('catalog is invalid.');
    }
    if (catalogId == CatalogId.jpnEspMain) {
      return const RouteParseFailure('jpn-esp-main is not supported for Quiz.');
    }
    return RouteParseSuccess(QuizGameRoute(
      word: CatalogWordRef(catalogId: catalogId, wordId: wordId),
      displayHint: queryParameters[_displayHintParameter],
    ));
  }
}
