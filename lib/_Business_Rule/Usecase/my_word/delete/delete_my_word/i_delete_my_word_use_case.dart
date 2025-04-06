import 'package:my_dic/_Business_Rule/Usecase/my_word/delete/delete_my_word/delete_my_word_input_data.dart';

abstract class IDeleteMyWordUseCase {
  Future<bool> execute(DeleteMyWordInputData input);
}
