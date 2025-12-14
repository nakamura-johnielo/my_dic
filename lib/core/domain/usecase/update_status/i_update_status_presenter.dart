import 'package:my_dic/core/domain/usecase/update_status/update_status_output_data.dart';

abstract class IUpdateStatusPresenter {
  void execute(UpdateStatusOutputData input);
}
