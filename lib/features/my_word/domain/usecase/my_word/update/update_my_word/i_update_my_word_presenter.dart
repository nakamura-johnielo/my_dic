import 'package:my_dic/features/my_word/domain/usecase/my_word/update/update_my_word/update_my_word_output_data.dart';

abstract class IUpdateMyWordPresenter {
  void execute(UpdateMyWordOutputData input);
}
