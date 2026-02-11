import 'package:my_dic/core/shared/utils/result.dart';
import 'package:my_dic/features/jpn_esp_word_status/domain/usecase/update_jpn_esp_status/update_jpn_esp_status_input_data.dart';

abstract class IUpdateJpnEspStatusUseCase {
    Future<Result<void>> execute(UpdateJpnEspStatusInputData input);
}
