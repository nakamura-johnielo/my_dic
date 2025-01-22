import 'package:my_dic/_Business_Rule/Usecase/delete_filter/delete_filter_input_data.dart';
import 'package:my_dic/_Business_Rule/Usecase/delete_filter/delete_filter_output_data.dart';

abstract class IDeleteFilterUseCase {
  void execute(DeleteFilterInputData input);
}
