import 'package:my_dic/features/my_word/domain/usecase/my_word/update/update_my_word/update_my_word_input_data.dart';

abstract class IUpdateMyWordUseCase {
  Future<bool> execute(UpdateMyWordInputData input);
}
