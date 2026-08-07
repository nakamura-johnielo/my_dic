import 'package:my_dic/core/application/usecase/fetch_dictionary/fetch_dictionary_input_data.dart';
import 'package:my_dic/core/application/usecase/fetch_dictionary/i_fetch_dictionary_use_case.dart';
import 'package:my_dic/core/domain/entity/dictionary/esj_dictionary.dart';
import 'package:my_dic/core/domain/i_repository/i_esj_dictionary_repository.dart';
import 'package:my_dic/core/shared/utils/result.dart';

class FetchEspJpnDictionaryInteractor implements IFetchEspJpnDictionaryUseCase {
  final IEsjDictionaryRepository _repository;

  FetchEspJpnDictionaryInteractor(this._repository);

  @override
  Future<Result<List<EspJpnDictionary>>> execute(
    FetchDictionaryInputData input,
  ) =>
      _repository.getDictionaryByWordId(input.wordId);
}
