import 'package:my_dic/features/esp_jpn_word_status/domain/usecase/update_status/update_status_output_data.dart';

abstract class IUpdateStatusPresenter {
  void execute(UpdateStatusOutputData input);
}
