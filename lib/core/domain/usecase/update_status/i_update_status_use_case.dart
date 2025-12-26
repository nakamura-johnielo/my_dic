import 'package:my_dic/core/shared/utils/result.dart';
import 'package:my_dic/core/domain/usecase/update_status/update_status_input_data.dart';

abstract class IUpdateStatusUseCase {
    Future<Result<void>> execute(UpdateStatusInputData input);
}
