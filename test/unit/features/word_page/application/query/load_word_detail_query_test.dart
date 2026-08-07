import 'package:flutter_test/flutter_test.dart';
import 'package:my_dic/core/domain/entity/dictionary/esj_dictionary.dart';
import 'package:my_dic/core/domain/entity/jpn_esp/jpn_esp_dictionary.dart';
import 'package:my_dic/core/domain/entity/verb/conjugacion/conjugacion_search_result_item.dart';
import 'package:my_dic/core/domain/entity/verb/conjugacion/result_conjugacions.dart';
import 'package:my_dic/core/domain/entity/verb/conjugacions.dart';
import 'package:my_dic/core/domain/i_repository/i_conjugation_repository.dart';
import 'package:my_dic/core/domain/i_repository/i_esj_dictionary_repository.dart';
import 'package:my_dic/core/domain/i_repository/i_jpn_esp_dictionary_repository.dart';
import 'package:my_dic/core/shared/enums/word/word_type.dart';
import 'package:my_dic/core/shared/errors/domain_errors.dart';
import 'package:my_dic/core/shared/utils/result.dart';
import 'package:my_dic/features/word_page/application/query/load_word_detail_query.dart';
import 'package:my_dic/features/word_page/application/query/word_detail_query.dart';
import 'package:my_dic/features/word_page/application/query/word_detail_view_data.dart';

void main() {
  const espQuery = WordDetailQuery(
    wordId: 1,
    wordType: WordType.espJpn,
    hasConjugation: true,
  );

  test('returns full EspJpn catalog content and optional conjugation',
      () async {
    const dictionary = EspJpnDictionary(
      dictionaryId: 1,
      word: 'hablar',
      content: '<p>full content</p>',
    );
    final query = _query(
      esp: Result.success([dictionary]),
      conjugation: Result.success(null),
    );

    final result = await query.execute(espQuery);
    final data = result.dataOrNull!.viewData as EspJpnWordDetailViewData;

    expect(data.dictionaries.single, same(dictionary));
    expect(data.dictionaries.single.content, '<p>full content</p>');
    expect(data.conjugation, isNull);
  });

  test('returns JpnEsp catalog content for its direction', () async {
    const dictionary = JpnEspDictionary(id: 2, wordId: 3, word: '話す');
    final result = await _query(jpn: Result.success([dictionary])).execute(
      const WordDetailQuery(
        wordId: 3,
        wordType: WordType.jpnEsp,
        hasConjugation: false,
      ),
    );

    final data = result.dataOrNull!.viewData as JpnEspWordDetailViewData;
    expect(data.dictionaries.single, same(dictionary));
  });

  test('propagates primary dictionary failure', () async {
    final error = BusinessRuleError(message: 'dictionary failed');
    final result = await _query(esp: Result.failure(error)).execute(espQuery);

    expect(result.errorOrNull, same(error));
  });

  test('retains dictionary data and reports conjugation failure as issue',
      () async {
    final error = BusinessRuleError(message: 'conjugation failed');
    final result = await _query(
      esp: Result.success(
          const [EspJpnDictionary(dictionaryId: 1, word: 'hablar')]),
      conjugation: Result.failure(error),
    ).execute(espQuery);

    expect(result.dataOrNull!.viewData, isA<EspJpnWordDetailViewData>());
    expect(result.dataOrNull!.issue?.source, 'conjugation');
    expect(result.dataOrNull!.issue?.error, same(error));
  });
}

LoadWordDetailQuery _query({
  Result<List<EspJpnDictionary>>? esp,
  Result<List<JpnEspDictionary>>? jpn,
  Result<EspConjugacions?>? conjugation,
}) =>
    LoadWordDetailQuery(
      _EspRepository(esp ?? Result.success(const [])),
      _JpnRepository(jpn ?? Result.success(const [])),
      _ConjugationRepository(conjugation ?? Result.success(null)),
    );

class _EspRepository implements IEsjDictionaryRepository {
  _EspRepository(this.result);
  final Result<List<EspJpnDictionary>> result;
  @override
  Future<Result<List<EspJpnDictionary>>> getDictionaryByWordId(int id) async =>
      result;
}

class _JpnRepository implements IJpnEspDictionaryRepository {
  _JpnRepository(this.result);
  final Result<List<JpnEspDictionary>> result;
  @override
  Future<Result<List<JpnEspDictionary>>> getDictionaryByWordId(
          int wordId) async =>
      result;
}

class _ConjugationRepository implements IConjugacionsRepository {
  _ConjugationRepository(this.result);
  final Result<EspConjugacions?> result;
  @override
  Future<Result<EspConjugacions?>> getConjugacionByWordId(int id) async =>
      result;
  @override
  Future<Result<List<SearchResultConjugacions>>> getConjugacionByWordWithPage(
    String word,
    int size,
    int currentPage,
  ) =>
      throw UnimplementedError();
  @override
  Future<Result<List<ConjugacionSearchResultItem>>>
      getQuizConjugacionByWordWithPage(
    String word,
    int size,
    int currentPage,
  ) =>
          throw UnimplementedError();
  @override
  Future<Result<bool>> hasConjByWordId(int wordId) =>
      throw UnimplementedError();
}
