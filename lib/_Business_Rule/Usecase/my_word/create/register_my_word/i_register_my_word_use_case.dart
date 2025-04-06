import 'package:my_dic/_Business_Rule/Usecase/my_word/create/register_my_word/register_my_word_input_data.dart';

abstract class IRegisterMyWordUseCase {
  Future<bool> execute(RegisterMyWordInputData input);
}
