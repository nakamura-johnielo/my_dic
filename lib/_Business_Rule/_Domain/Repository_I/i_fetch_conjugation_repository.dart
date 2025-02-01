import 'package:my_dic/_Business_Rule/Usecase/fetch_conjugation/fetch_conjugation_repository_input_data.dart';

abstract class IFetchConjugationRepository  {
	Future<String> getById(int id);
	Future<String> getBySomething(FetchConjugationRepositoryInputData input);
	
}
