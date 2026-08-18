import 'package:flutter_test/flutter_test.dart';
import 'package:my_dic/app/routing/route_definitions.dart';
import 'package:my_dic/core/result/route_parse_result.dart';
import 'package:my_dic/features/quiz/port/route.dart';
import 'package:my_dic/features/word_detail/port/word_detail.dart';

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
      );
      final unsupportedType = WordDetailRoute.parse(
        pathParameters: const {'wordId': '42'},
        queryParameters: const {'type': 'espEng'},
      );
      final conflict = WordDetailRoute.parse(
        pathParameters: const {'wordId': '42'},
        queryParameters: const {'catalog': 'esp-jpn-main', 'type': 'jpnEsp'},
      );
      final missingIdentity = WordDetailRoute.parse(
        pathParameters: const {'wordId': '42'},
        queryParameters: const {},
      );

      expect(unknownCatalog, isA<RouteParseFailure<WordDetailRoute>>());
      expect(unsupportedType, isA<RouteParseFailure<WordDetailRoute>>());
      expect(conflict, isA<RouteParseFailure<WordDetailRoute>>());
      expect(missingIdentity, isA<RouteParseFailure<WordDetailRoute>>());
    });
  });

  group('QuizGameRoute', () {
    test('registers canonical and unnamed legacy paths together', () {
      final routes = flashCardRoutes('quiz-game', wordDetailRouteName: 'word');

      expect(routes, hasLength(2));
      expect(routes.first.path, QuizGameRoute.path);
      expect(routes.first.name, 'quiz-game');
      expect(routes.last.path, QuizGameRoute.legacyPath);
      expect(routes.last.name, isNull);
    });

    test('serializes and parses the canonical refresh-safe URL payload', () {
      const route = QuizGameRoute(
        word: CatalogWordRef(catalogId: CatalogId.espJpnMain, wordId: 42),
        displayHint: 'hablar',
      );
      final result = QuizGameRoute.parse(
        pathParameters: route.pathParameters,
        queryParameters: route.queryParameters,
      );

      expect(QuizGameRoute.path, 'quiz-game/:catalog/:wordId');
      expect(route.pathParameters,
          const {'catalog': 'esp-jpn-main', 'wordId': '42'});
      expect(route.queryParameters, const {'word': 'hablar'});
      expect(result, isA<RouteParseSuccess<QuizGameRoute>>());
      expect((result as RouteParseSuccess<QuizGameRoute>).value.displayHint,
          'hablar');
    });

    test('accepts the legacy URL as Esp-Jpn', () {
      final result = QuizGameRoute.parse(
        pathParameters: const {'wordId': '42'},
        queryParameters: const {'word': 'hablar'},
      );

      expect(QuizGameRoute.legacyPath, 'quiz-game/:wordId');
      expect(result, isA<RouteParseSuccess<QuizGameRoute>>());
      final route = (result as RouteParseSuccess<QuizGameRoute>).value;
      expect(route.word,
          const CatalogWordRef(catalogId: CatalogId.espJpnMain, wordId: 42));
      expect(route.displayHint, 'hablar');
    });

    test('rejects invalid identity and unsupported catalogs', () {
      final nonPositive = QuizGameRoute.parse(
        pathParameters: const {'catalog': 'esp-jpn-main', 'wordId': '0'},
        queryParameters: const {},
      );
      final unknownCatalog = QuizGameRoute.parse(
        pathParameters: const {'catalog': 'unknown', 'wordId': '42'},
        queryParameters: const {},
      );
      final unsupportedCatalog = QuizGameRoute.parse(
        pathParameters: const {'catalog': 'jpn-esp-main', 'wordId': '42'},
        queryParameters: const {},
      );

      expect(nonPositive, isA<RouteParseFailure<QuizGameRoute>>());
      expect(unknownCatalog, isA<RouteParseFailure<QuizGameRoute>>());
      expect(unsupportedCatalog, isA<RouteParseFailure<QuizGameRoute>>());
    });
  });
}
