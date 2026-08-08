import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:my_dic/core/application/query/query_issue.dart';
import 'package:my_dic/core/shared/errors/domain_errors.dart';
import 'package:my_dic/core/shared/utils/result.dart';
import 'package:my_dic/features/catalog/port/catalog_id.dart';
import 'package:my_dic/features/catalog/port/catalog_word_ref.dart';
import 'package:my_dic/features/catalog/port/model/esp_jpn_entry.dart';
import 'package:my_dic/features/catalog/port/model/jpn_esp_entry.dart';
import 'package:my_dic/features/word_page/application/query/query.dart';

void main() {
  const word = CatalogWordRef(catalogId: CatalogId.espJpnMain, wordId: 42);

  test('WordDetailQuery retains the catalog-owned word identity', () {
    const query = WordDetailQuery(word: word);
    expect(query.word, word);
  });

  group('WordDetailViewData', () {
    test('preserves immutable EspJpn Catalog entries', () {
      final entry = EspJpnEntry(dictionaryId: 1, word: 'hablar');
      final data = EspJpnWordDetailViewData(word: word, entries: [entry]);

      expect(data.word, word);
      expect(data.entries.single, same(entry));
      expect(() => data.entries.add(entry), throwsUnsupportedError);
    });

    test('preserves immutable JpnEsp Catalog entries', () {
      const jpnWord =
          CatalogWordRef(catalogId: CatalogId.jpnEspMain, wordId: 9);
      final entry = JpnEspEntry(dictionaryId: 1, wordId: 9, word: '日本語');
      final data = JpnEspWordDetailViewData(word: jpnWord, entries: [entry]);

      expect(data.word, jpnWord);
      expect(data.entries.single, same(entry));
      expect(() => data.entries.add(entry), throwsUnsupportedError);
    });
  });

  test('WordDetailQueryResult retains an optional query issue', () {
    final issue = QueryIssue(
      source: 'conjugation',
      error: BusinessRuleError(message: 'conjugation unavailable'),
    );
    final viewData = JpnEspWordDetailViewData(word: word, entries: const []);
    final result = WordDetailQueryResult(viewData: viewData, issue: issue);

    expect(result.viewData, same(viewData));
    expect(result.issue, same(issue));
  });

  test('ILoadWordDetailQuery expresses a typed Result boundary', () async {
    final result = await _Loader().execute(const WordDetailQuery(word: word));
    expect(result, isA<Success<WordDetailQueryResult>>());
  });

  test('query models do not import Flutter, Drift, or legacy repositories', () {
    final directory = Directory('lib/features/word_page/application/query');
    final source = directory
        .listSync(recursive: true)
        .whereType<File>()
        .where((file) => file.path.endsWith('.dart'))
        .map((file) => file.readAsStringSync())
        .join('\n');

    expect(source, isNot(contains('package:flutter/')));
    expect(source, isNot(contains('package:drift/')));
    expect(source, isNot(contains('core/domain/i_repository/')));
  });
}

class _Loader implements ILoadWordDetailQuery {
  @override
  Future<Result<WordDetailQueryResult>> execute(WordDetailQuery query) async =>
      Result.success(WordDetailQueryResult(
        viewData: JpnEspWordDetailViewData(word: query.word, entries: const []),
      ));
}
