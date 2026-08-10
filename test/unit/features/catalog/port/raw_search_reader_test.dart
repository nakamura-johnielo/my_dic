import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:my_dic/features/catalog/port/catalog_id.dart';
import 'package:my_dic/features/catalog/port/catalog_word_ref.dart';
import 'package:my_dic/features/catalog/port/raw_search_reader.dart';

void main() {
  test('raw search request is zero-based and raw hits retain Catalog identity',
      () {
    const word = CatalogWordRef(catalogId: CatalogId.espJpnMain, wordId: 7);
    const query = CatalogRawSearchQuery(
      catalogId: CatalogId.espJpnMain,
      text: 'hab',
      page: 0,
      size: 20,
    );
    final hit = CatalogConjugationRawHit(
      word: word,
      headword: 'hablar',
      matches: const {'indicative_present_yo': 'hablo'},
    );

    expect(query.page, 0);
    expect(hit.word, word);
    expect(
        () => hit.matches['imperative_tu'] = 'habla', throwsUnsupportedError);
  });

  test('Catalog and Search port sources do not import framework packages', () {
    final files = [
      ...Directory('lib/features/search/port')
          .listSync(recursive: true)
          .whereType<File>(),
      File('lib/features/catalog/port/raw_search_reader.dart'),
    ].where((file) => file.path.endsWith('.dart'));
    final forbidden = RegExp(
      r'''import\s+['"]package:(?:flutter|flutter_riverpod|drift)/''',
    );

    for (final file in files) {
      expect(forbidden.hasMatch(file.readAsStringSync()), isFalse,
          reason: '${file.path} must be provider-neutral.');
    }
  });
}
