import 'package:my_dic/core/result/route_parse_result.dart';
import 'package:my_dic/features/catalog/port/catalog.dart'
    show CatalogId, CatalogWordRef;

/// URL-serializable contract for the word detail screen.
///
/// This deliberately contains only plain data and has no Flutter dependency.
final class WordDetailRoute {
  const WordDetailRoute({required this.word});

  static const path = 'word/:wordId';
  static const _catalogParameter = 'catalog';
  static const _legacyTypeParameter = 'type';

  final CatalogWordRef word;

  Map<String, String> get pathParameters => {'wordId': '${word.wordId}'};

  Map<String, String> get queryParameters => {
        _catalogParameter: word.catalogId.wireValue,
      };

  static RouteParseResult<WordDetailRoute> parse({
    required Map<String, String> pathParameters,
    required Map<String, String> queryParameters,
  }) {
    final wordId = int.tryParse(pathParameters['wordId'] ?? '');

    if (wordId == null || wordId <= 0) {
      return const RouteParseFailure('wordId must be a positive integer.');
    }

    final catalogValue = queryParameters[_catalogParameter];
    final catalogId =
        catalogValue == null ? null : CatalogId.tryParse(catalogValue);
    if (catalogValue != null && catalogId == null) {
      return const RouteParseFailure('catalog is invalid.');
    }

    final legacyType = queryParameters[_legacyTypeParameter];
    final legacyCatalogId = legacyType == null ? null : _legacyCatalog(legacyType);
    if (legacyType != null && legacyCatalogId == null) {
      return const RouteParseFailure('type is invalid.');
    }
    if (catalogId != null &&
        legacyCatalogId != null &&
        catalogId != legacyCatalogId) {
      return const RouteParseFailure('catalog and type conflict.');
    }

    final resolvedCatalogId = catalogId ?? legacyCatalogId;
    if (resolvedCatalogId == null) {
      return const RouteParseFailure('catalog is missing.');
    }

    return RouteParseSuccess(WordDetailRoute(
      word: CatalogWordRef(catalogId: resolvedCatalogId, wordId: wordId),
    ));
  }

  static CatalogId? _legacyCatalog(String type) => switch (type) {
        'espJpn' => CatalogId.espJpnMain,
        'jpnEsp' => CatalogId.jpnEspMain,
        _ => null,
      };
}
