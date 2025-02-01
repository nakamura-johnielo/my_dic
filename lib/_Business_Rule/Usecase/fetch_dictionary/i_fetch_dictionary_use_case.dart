import 'package:my_dic/_Business_Rule/Usecase/fetch_dictionary/fetch_dictionary_input_data.dart';

abstract class IFetchDictionaryUseCase {
  Future<void> execute(FetchDictionaryInputData input);
}
