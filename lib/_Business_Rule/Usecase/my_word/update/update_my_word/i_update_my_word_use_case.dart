import 'package:my_dic/_Business_Rule/Usecase/my_word/update/update_my_word/update_my_word_input_data.dart';

abstract class IUpdateMyWordUseCase {
  Future<bool> execute(UpdateMyWordInputData input);
}
