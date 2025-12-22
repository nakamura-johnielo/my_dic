import 'package:my_dic/features/my_word/domain/usecase/my_word/delete/handle_word_delete/handle_word_delete_input_data.dart';

abstract class IHandleWordDeleteUseCase {
  void execute(HandleWordDeleteInputData input);
}
