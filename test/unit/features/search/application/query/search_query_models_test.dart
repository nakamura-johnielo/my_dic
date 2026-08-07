import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:my_dic/core/application/query/query_issue.dart';
import 'package:my_dic/core/shared/enums/conjugacion/enum_mood_tense_subject.dart';
import 'package:my_dic/core/shared/errors/domain_errors.dart';
import 'package:my_dic/features/search/application/query/search_query_models.dart';

void main() {
  const item = SearchResultItem(
    wordId: 1,
    headword: 'hablar',
    direction: SearchDirection.espJpn,
    hasConjugation: true,
    meaningText: '話す',
    rankingNo: 12,
    starCount: 3,
  );
  final issue = QueryIssue(
    source: 'ranking',
    error: ValidationError(message: 'Ranking unavailable'),
  );

  group('Search application query models', () {
    test('SearchQuery requires an explicit valid pagination contract', () {
      const query = SearchQuery(
        text: 'hablar',
        direction: SearchDirection.espJpn,
        page: 0,
        size: 20,
        includeConjugationSuggestions: true,
      );

      expect(query.page, 0);
      expect(query.size, 20);
      expect(
        () => SearchQuery(
          text: 'hablar',
          direction: SearchDirection.espJpn,
          page: -1,
          size: 20,
          includeConjugationSuggestions: false,
        ),
        throwsA(isA<AssertionError>()),
      );
      expect(
        () => SearchQuery(
          text: 'hablar',
          direction: SearchDirection.espJpn,
          page: 0,
          size: 0,
          includeConjugationSuggestions: false,
        ),
        throwsA(isA<AssertionError>()),
      );
    });

    test('result page defensively copies every list', () {
      final items = <SearchResultItem>[item];
      final suggestions = <ConjugationSearchItem>[
        ConjugationSearchItem(
          wordId: 1,
          headword: 'hablar',
          matches: const {MoodTenseSubject.indicativePresentYo: 'hablo'},
          meaningText: '話す',
          rankingNo: 12,
          starCount: 3,
        ),
      ];
      final issues = <QueryIssue>[issue];

      final page = SearchResultPage(
        items: items,
        conjugationSuggestions: suggestions,
        hasNext: true,
        issues: issues,
      );
      items.clear();
      suggestions.clear();
      issues.clear();

      expect(page.items, [item]);
      expect(page.conjugationSuggestions, hasLength(1));
      expect(page.issues, [issue]);
      expect(() => page.items.add(item), throwsUnsupportedError);
      expect(
        () => page.conjugationSuggestions.clear(),
        throwsUnsupportedError,
      );
      expect(() => page.issues.clear(), throwsUnsupportedError);
    });

    test('conjugation item defensively copies matches', () {
      final matches = <MoodTenseSubject, String>{
        MoodTenseSubject.indicativePresentYo: 'hablo',
      };
      final item = ConjugationSearchItem(
        wordId: 1,
        headword: 'hablar',
        matches: matches,
        meaningText: '話す',
        rankingNo: null,
        starCount: null,
      );
      matches[MoodTenseSubject.indicativePresentYo] = 'changed';

      expect(item.matches[MoodTenseSubject.indicativePresentYo], 'hablo');
      expect(
        () => item.matches[MoodTenseSubject.indicativePresentYo] = 'other',
        throwsUnsupportedError,
      );
    });

    test('query model sources do not depend on framework or Drift packages',
        () {
      final queryDirectory = Directory(
        'lib/features/search/application/query',
      );
      final forbiddenImports = RegExp(
        r'''import\s+['"]package:(?:flutter|flutter_riverpod|drift)/''',
      );

      for (final source in queryDirectory
          .listSync(recursive: true)
          .whereType<File>()
          .where((file) => file.path.endsWith('.dart'))) {
        expect(
          forbiddenImports.hasMatch(source.readAsStringSync()),
          isFalse,
          reason: '${source.path} must remain a plain Dart application model.',
        );
      }
    });
  });
}
