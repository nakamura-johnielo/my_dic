import 'package:my_dic/core/domain/usecase/update_status/update_status_input_data.dart';

abstract class IUpdateStatusUseCase {
  void execute(UpdateStatusInputData input);
}
