import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:my_dic/features/catalog/port/catalog.dart';
import 'package:my_dic/features/quiz/port/catalog_gateway.dart';
import 'package:my_dic/features/quiz/port/candidate_query.dart';

void main() {
  test('candidate contracts retain Catalog identity and zero-based pagination',
      () {
    const word = CatalogWordRef(catalogId: CatalogId.espJpnMain, wordId: 3);
    const query = QuizCandidateQuery(text: 'hab', page: 0, size: 10);
    const raw = QuizConjugationCandidate(word: word, headword: 'hablar');
    const candidate = QuizCandidate(
        word: word,
        headword: 'hablar',
        meaningText: null,
        rankingNo: null,
        starCount: null);

    expect(query.page, 0);
    expect(raw.word, word);
    expect(candidate, candidate);
  });

  test('Quiz and Catalog port sources contain no framework imports', () {
    final files = [
      File('lib/features/quiz/port/catalog_gateway.dart'),
      File('lib/features/quiz/port/candidate_source.dart'),
      File('lib/features/quiz/port/candidate_query.dart'),
      File('lib/features/quiz/port/error/quiz_catalog_gateway_error.dart'),
      ...Directory('lib/features/quiz/port/model')
          .listSync(recursive: true)
          .whereType<File>(),
    ].where((file) => file.path.endsWith('.dart'));
    final forbidden =
        RegExp(r'''import\s+['"]package:(?:flutter|flutter_riverpod|drift)/''');
    for (final file in files) {
      expect(forbidden.hasMatch(file.readAsStringSync()), isFalse);
    }
  });
}
