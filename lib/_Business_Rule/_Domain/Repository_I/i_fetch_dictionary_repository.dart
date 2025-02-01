import 'package:my_dic/_Business_Rule/Usecase/fetch_dictionary/fetch_dictionary_repository_input_data.dart';

abstract class IFetchDictionaryRepository  {
	Future<String> getById(int id);
	Future<String> getBySomething(FetchDictionaryRepositoryInputData input);
	
}
