import 'package:my_dic/features/my_word/domain/usecase/my_word/update/handle_word_update/handle_word_update_input_data.dart';

abstract class IHandleWordUpdateUseCase {
  void execute(HandleWordUpdateInputData input);
}
