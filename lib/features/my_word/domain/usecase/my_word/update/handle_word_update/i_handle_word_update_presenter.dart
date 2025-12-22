import 'package:my_dic/features/my_word/domain/usecase/my_word/update/handle_word_update/handle_word_update_output_data.dart';

abstract class IHandleWordUpdatePresenter {
  void execute(HandleWordUpdateOutputData input);
}
