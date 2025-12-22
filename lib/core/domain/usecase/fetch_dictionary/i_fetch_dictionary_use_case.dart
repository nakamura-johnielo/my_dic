import 'package:my_dic/core/domain/entity/dictionary/esj_dictionary.dart';
import 'package:my_dic/core/domain/usecase/fetch_dictionary/fetch_dictionary_input_data.dart';

abstract class IFetchEspJpnDictionaryUseCase {
  Future<List<EspJpnDictionary>> execute(FetchDictionaryInputData input);
}
