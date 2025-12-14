import 'package:my_dic/core/domain/usecase/fetch_dictionary/fetch_dictionary_input_data.dart';

abstract class IFetchDictionaryUseCase {
  Future<void> execute(FetchDictionaryInputData input);
}
