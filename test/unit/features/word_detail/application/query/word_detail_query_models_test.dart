import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:my_dic/features/word_detail/port/word_detail.dart';

void main() {
  const word = CatalogWordRef(catalogId: CatalogId.espJpnMain, wordId: 42);

  test('WordDetailQuery retains the catalog-owned word identity', () {
    final query = WordDetailQuery(word: word);
    expect(query.word, word);
    expect(query, WordDetailQuery(word: word));
  });

  group('WordDetailData', () {
    test('preserves immutable EspJpn entries', () {
      final entry = WordDetailEspJpnEntry(
        dictionaryId: 1,
        word: 'hablar',
        headword: WordDetailContent.text('hablar'),
        content: WordDetailContent.text('話す'),
      );
      final entries = [entry];
      final data = EspJpnWordDetailData(word: word, entries: entries);
      entries.clear();

      expect(data.word, word);
      expect(data.entries.single, same(entry));
      expect(() => data.entries.add(entry), throwsUnsupportedError);
    });

    test('preserves immutable JpnEsp entries', () {
      const jpnWord =
          CatalogWordRef(catalogId: CatalogId.jpnEspMain, wordId: 9);
      final entry = WordDetailJpnEspEntry(
        dictionaryId: 1,
        wordId: 9,
        word: '日本語',
        headword: WordDetailContent.text('日本語'),
        content: WordDetailContent.text('japonés'),
      );
      final entries = [entry];
      final data = JpnEspWordDetailData(word: jpnWord, entries: entries);
      entries.clear();

      expect(data.word, jpnWord);
      expect(data.entries.single, same(entry));
      expect(() => data.entries.add(entry), throwsUnsupportedError);
    });
  });

  test('WordDetailResult retains immutable typed conjugation issues', () {
    const error = WordDetailDataUnavailableError(
      message: 'conjugation unavailable',
    );
    const issue = WordDetailConjugationIssue(error: error);
    final data = EspJpnWordDetailData(word: word, entries: const []);
    final issues = <WordDetailIssue>[issue];
    final result = WordDetailResult(data: data, issues: issues);
    issues.clear();

    expect(result.data, same(data));
    expect(result.issues.single, same(issue));
    expect(result.issues.single, isA<WordDetailConjugationIssue>());
    expect(result.issues.single.error, isA<WordDetailReadError>());
    expect(() => result.issues.clear(), throwsUnsupportedError);
  });

  test('WordDetailReaderPort expresses a typed Result boundary', () async {
    final result = await _Reader().read(WordDetailQuery(word: word));
    expect(result, isA<Success<WordDetailResult>>());
  });

  test('business facade contracts remain pure Dart', () {
    const files = [
      'lib/features/word_detail/port/word_detail.dart',
      'lib/features/word_detail/port/word_detail_query.dart',
      'lib/features/word_detail/port/error/word_detail_read_error.dart',
      'lib/features/word_detail/port/gateway/word_detail_catalog_gateway.dart',
      'lib/features/word_detail/port/model/word_detail_conjugation.dart',
      'lib/features/word_detail/port/model/word_detail_content_block.dart',
      'lib/features/word_detail/port/model/word_detail_data.dart',
      'lib/features/word_detail/port/model/word_detail_entry.dart',
      'lib/features/word_detail/port/model/word_detail_issue.dart',
      'lib/features/word_detail/port/reader/word_detail_reader_port.dart',
      'lib/features/word_detail/port/result/word_detail_result.dart',
    ];
    final source = files.map((path) => File(path).readAsStringSync()).join();

    expect(source, isNot(contains('package:flutter/')));
    expect(source, isNot(contains('package:flutter_riverpod/')));
    expect(source, isNot(contains('package:drift/')));
    expect(source, isNot(contains('features/word_detail/internal/')));
  });
}

final class _Reader implements WordDetailReaderPort {
  @override
  Future<Result<WordDetailResult>> read(WordDetailQuery query) async =>
      Result.success(
        WordDetailResult(
          data: EspJpnWordDetailData(word: query.word, entries: const []),
        ),
      );
}
