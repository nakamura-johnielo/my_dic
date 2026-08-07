import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:my_dic/core/application/query/query_issue.dart';
import 'package:my_dic/core/domain/entity/dictionary/esj_dictionary.dart';
import 'package:my_dic/core/domain/entity/dictionary/sub/example/impl/esp_jpn_example.dart';
import 'package:my_dic/core/domain/entity/dictionary/sub/idiom/impl/idiom.dart';
import 'package:my_dic/core/domain/entity/dictionary/sub/supplement.dart';
import 'package:my_dic/core/domain/entity/jpn_esp/example/jpn_esp_example.dart';
import 'package:my_dic/core/domain/entity/jpn_esp/jpn_esp_dictionary.dart';
import 'package:my_dic/core/shared/enums/word/word_type.dart';
import 'package:my_dic/core/shared/errors/domain_errors.dart';
import 'package:my_dic/core/shared/utils/result.dart';
import 'package:my_dic/features/word_page/application/query/query.dart';

void main() {
  group('WordDetailQuery', () {
    test('retains all request dimensions', () {
      const query = WordDetailQuery(
        wordId: 42,
        wordType: WordType.espJpn,
        hasConjugation: true,
      );

      expect(query.wordId, 42);
      expect(query.wordType, WordType.espJpn);
      expect(query.hasConjugation, isTrue);
    });
  });

  group('WordDetailViewData', () {
    test('preserves full nested EspJpn catalog content', () {
      const example = EspJpnExample(
        exampleId: 2,
        japanese: '話す',
        espanol: 'hablar',
      );
      const idiom =
          Idiom(idiomId: 3, idiom: 'hablar claro', description: '率直に話す');
      const supplement = Supplement(supplementId: 4, supplement: '補足');
      const dictionary = EspJpnDictionary(
        dictionaryId: 1,
        word: 'hablar',
        content: '<p>完全な本文</p>',
        examples: [example],
        idioms: [idiom],
        supplements: [supplement],
      );

      final data = EspJpnWordDetailViewData(dictionaries: [dictionary]);

      expect(data.dictionaries.single, same(dictionary));
      expect(data.dictionaries.single.content, '<p>完全な本文</p>');
      expect(data.dictionaries.single.examples, [example]);
      expect(data.dictionaries.single.idioms, [idiom]);
      expect(data.dictionaries.single.supplements, [supplement]);
      expect(() => data.dictionaries.add(dictionary), throwsUnsupportedError);
    });

    test('preserves full nested JpnEsp catalog content', () {
      const example = JpnEspExampleWith(
        exampleId: 2,
        japanese: '話す',
        espanol: 'hablar',
        espanolHtml: '<b>hablar</b>',
      );
      const dictionary = JpnEspDictionary(
        id: 1,
        wordId: 9,
        word: '話す',
        content: '<p>完全な本文</p>',
        examples: [example],
      );

      final data = JpnEspWordDetailViewData(dictionaries: [dictionary]);

      expect(data.dictionaries.single, same(dictionary));
      expect(data.dictionaries.single.content, '<p>完全な本文</p>');
      expect(data.dictionaries.single.examples, [example]);
    });
  });

  test('WordDetailQueryResult retains an optional query issue', () {
    final issue = QueryIssue(
      source: 'conjugation',
      error: BusinessRuleError(message: 'conjugation unavailable'),
    );
    final viewData = JpnEspWordDetailViewData(dictionaries: const []);
    final result = WordDetailQueryResult(viewData: viewData, issue: issue);

    expect(result.viewData, same(viewData));
    expect(result.issue, same(issue));
  });

  test('ILoadWordDetailQuery expresses a typed Result boundary', () async {
    final loader = _Loader();
    final result = await loader.execute(const WordDetailQuery(
      wordId: 1,
      wordType: WordType.jpnEsp,
      hasConjugation: false,
    ));

    expect(result, isA<Success<WordDetailQueryResult>>());
  });

  test('query models do not import Flutter or Drift', () {
    final directory = Directory('lib/features/word_page/application/query');
    final source = directory
        .listSync(recursive: true)
        .whereType<File>()
        .where((file) => file.path.endsWith('.dart'))
        .map((file) => file.readAsStringSync())
        .join('\n');

    expect(source, isNot(contains('package:flutter/')));
    expect(source, isNot(contains('package:drift/')));
  });
}

class _Loader implements ILoadWordDetailQuery {
  @override
  Future<Result<WordDetailQueryResult>> execute(WordDetailQuery query) async =>
      Result.success(WordDetailQueryResult(
        viewData: JpnEspWordDetailViewData(dictionaries: const []),
      ));
}
