import 'package:flutter_test/flutter_test.dart';
import 'package:my_dic/core/application/usecase/fetch_conjugation/fetch_conjugation_input_data.dart';
import 'package:my_dic/core/application/usecase/fetch_conjugation/fetch_conjugation_interactor.dart';
import 'package:my_dic/core/application/usecase/fetch_dictionary/fetch_dictionary_input_data.dart';
import 'package:my_dic/core/application/usecase/fetch_dictionary/fetch_dictionary_interactor.dart';
import 'package:my_dic/core/application/usecase/fetch_jpn_esp_dictionary/fetch_jpn_esp_dictionary_input_data.dart';
import 'package:my_dic/core/application/usecase/fetch_jpn_esp_dictionary/fetch_jpn_esp_dictionary_interactor.dart';
import 'package:my_dic/core/domain/entity/dictionary/esj_dictionary.dart';
import 'package:my_dic/core/domain/entity/jpn_esp/jpn_esp_dictionary.dart';
import 'package:my_dic/core/domain/entity/verb/conjugacions.dart';
import 'package:my_dic/core/domain/entity/verb/conjugacion/conjugacion_search_result_item.dart';
import 'package:my_dic/core/domain/entity/verb/conjugacion/result_conjugacions.dart';
import 'package:my_dic/core/domain/i_repository/i_conjugation_repository.dart';
import 'package:my_dic/core/domain/i_repository/i_esj_dictionary_repository.dart';
import 'package:my_dic/core/domain/i_repository/i_jpn_esp_dictionary_repository.dart';
import 'package:my_dic/core/shared/utils/result.dart';

class _EspJpnRepository implements IEsjDictionaryRepository {
  int? receivedWordId;

  @override
  Future<Result<List<EspJpnDictionary>>> getDictionaryByWordId(int id) async {
    receivedWordId = id;
    return Result.success([]);
  }
}

class _ConjugationRepository implements IConjugacionsRepository {
  int? receivedWordId;

  @override
  Future<Result<EspConjugacions?>> getConjugacionByWordId(int id) async {
    receivedWordId = id;
    return Result.success(null);
  }

  @override
  Future<Result<List<SearchResultConjugacions>>> getConjugacionByWordWithPage(
          String word, int size, int currentPage) =>
      throw UnimplementedError();

  @override
  Future<Result<List<ConjugacionSearchResultItem>>>
      getQuizConjugacionByWordWithPage(
              String word, int size, int currentPage) =>
          throw UnimplementedError();

  @override
  Future<Result<bool>> hasConjByWordId(int wordId) =>
      throw UnimplementedError();
}

class _JpnEspRepository implements IJpnEspDictionaryRepository {
  int? receivedWordId;

  @override
  Future<Result<List<JpnEspDictionary>>> getDictionaryByWordId(
      int wordId) async {
    receivedWordId = wordId;
    return Result.success([]);
  }
}

void main() {
  test('catalog fetch use cases forward their application inputs to ports',
      () async {
    final espJpnRepository = _EspJpnRepository();
    final conjugationRepository = _ConjugationRepository();
    final jpnEspRepository = _JpnEspRepository();

    await FetchEspJpnDictionaryInteractor(espJpnRepository)
        .execute(const FetchDictionaryInputData(10));
    await FetchEspConjugationInteractor(conjugationRepository)
        .execute(const FetchConjugationInputData(20));
    await FetchJpnEspDictionaryInteractor(jpnEspRepository)
        .execute(const FetchJpnEspDictionaryInputData(30));

    expect(espJpnRepository.receivedWordId, 10);
    expect(conjugationRepository.receivedWordId, 20);
    expect(jpnEspRepository.receivedWordId, 30);
  });
}
