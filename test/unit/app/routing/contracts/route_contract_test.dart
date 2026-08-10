import 'package:flutter_test/flutter_test.dart';
import 'package:my_dic/core/result/route_parse_result.dart';
import 'package:my_dic/features/quiz/port/route.dart';
import 'package:my_dic/features/word_detail/port/route.dart';
import 'package:my_dic/features/catalog/port/catalog_id.dart';
import 'package:my_dic/features/catalog/port/catalog_word_ref.dart';

void main() {
  group('WordDetailRoute', () {
    test('serializes and parses a refresh-safe URL payload', () {
      const route = WordDetailRoute(
        word: CatalogWordRef(catalogId: CatalogId.espJpnMain, wordId: 42),
      );
      final result = WordDetailRoute.parse(
        pathParameters: route.pathParameters,
        queryParameters: route.queryParameters,
      );

      expect(result, isA<RouteParseSuccess<WordDetailRoute>>());
      final parsed = (result as RouteParseSuccess<WordDetailRoute>).value;
      expect(parsed.word, route.word);
      expect(route.queryParameters, const {'catalog': 'esp-jpn-main'});
    });

    test('accepts matching catalog and legacy type during the support window',
        () {
      final result = WordDetailRoute.parse(
        pathParameters: const {'wordId': '42'},
        queryParameters: const {
          'catalog': 'esp-jpn-main',
          'type': 'espJpn',
        },
        parseLegacyType: _legacyCatalogId,
      );

      expect(result, isA<RouteParseSuccess<WordDetailRoute>>());
    });

    test('rejects a non-positive word ID', () {
      final result = WordDetailRoute.parse(
        pathParameters: const {'wordId': '0'},
        queryParameters: const {'catalog': 'esp-jpn-main'},
      );
      expect(result, isA<RouteParseFailure<WordDetailRoute>>());
    });

    test('parses legacy type URLs and ignores every hasConj value', () {
      for (final hasConj in ['true', 'false', 'garbage']) {
        final result = WordDetailRoute.parse(
          pathParameters: const {'wordId': '42'},
          queryParameters: {'type': 'espJpn', 'hasConj': hasConj},
          parseLegacyType: _legacyCatalogId,
        );

        expect(result, isA<RouteParseSuccess<WordDetailRoute>>(),
            reason: hasConj);
        expect(
          (result as RouteParseSuccess<WordDetailRoute>).value.word,
          const CatalogWordRef(catalogId: CatalogId.espJpnMain, wordId: 42),
          reason: hasConj,
        );
      }
    });

    test('rejects unknown catalog, unsupported legacy type, and conflicts', () {
      final unknownCatalog = WordDetailRoute.parse(
        pathParameters: const {'wordId': '42'},
        queryParameters: const {'catalog': 'unknown'},
        parseLegacyType: _legacyCatalogId,
      );
      final unsupportedType = WordDetailRoute.parse(
        pathParameters: const {'wordId': '42'},
        queryParameters: const {'type': 'espEng'},
        parseLegacyType: _legacyCatalogId,
      );
      final conflict = WordDetailRoute.parse(
        pathParameters: const {'wordId': '42'},
        queryParameters: const {'catalog': 'esp-jpn-main', 'type': 'jpnEsp'},
        parseLegacyType: _legacyCatalogId,
      );
      final missingIdentity = WordDetailRoute.parse(
        pathParameters: const {'wordId': '42'},
        queryParameters: const {},
        parseLegacyType: _legacyCatalogId,
      );

      expect(unknownCatalog, isA<RouteParseFailure<WordDetailRoute>>());
      expect(unsupportedType, isA<RouteParseFailure<WordDetailRoute>>());
      expect(conflict, isA<RouteParseFailure<WordDetailRoute>>());
      expect(missingIdentity, isA<RouteParseFailure<WordDetailRoute>>());
    });
  });

  test('QuizGameRoute serializes and parses a refresh-safe URL payload', () {
    const route = QuizGameRoute(
      word: CatalogWordRef(catalogId: CatalogId.espJpnMain, wordId: 42),
      displayHint: 'hablar',
    );
    final result = QuizGameRoute.parse(
      pathParameters: route.pathParameters,
      queryParameters: route.queryParameters,
    );

    expect(result, isA<RouteParseSuccess<QuizGameRoute>>());
    expect((result as RouteParseSuccess<QuizGameRoute>).value.displayHint,
        'hablar');
  });
}

CatalogId? _legacyCatalogId(String type) => switch (type) {
      'espJpn' => CatalogId.espJpnMain,
      'jpnEsp' => CatalogId.jpnEspMain,
      _ => null,
    };
