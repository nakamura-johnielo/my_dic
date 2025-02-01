import 'package:my_dic/_Business_Rule/Usecase/update_status/update_status_repository_input_data.dart';

abstract class IUpdateStatusRepository  {
	Future<String> getById(int id);
	Future<String> getBySomething(UpdateStatusRepositoryInputData input);
	
}
