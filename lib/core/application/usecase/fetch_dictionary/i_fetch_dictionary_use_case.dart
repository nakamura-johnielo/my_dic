import 'package:my_dic/core/application/usecase/fetch_dictionary/fetch_dictionary_input_data.dart';
import 'package:my_dic/core/domain/entity/dictionary/esj_dictionary.dart';
import 'package:my_dic/core/shared/utils/result.dart';

abstract interface class IFetchEspJpnDictionaryUseCase {
  Future<Result<List<EspJpnDictionary>>> execute(
      FetchDictionaryInputData input);
}
