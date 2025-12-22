import 'package:my_dic/features/my_word/domain/usecase/my_word/delete/handle_word_delete/handle_word_delete_output_data.dart';

abstract class IHandleWordDeletePresenter {
  void execute(HandleWordDeleteOutputData input);
}
