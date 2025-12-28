import 'package:my_dic/core/shared/utils/result.dart';
import 'package:my_dic/features/my_word/domain/usecase/update_my_word_status/update_my_word_status_input_data.dart';

abstract class IUpdateMyWordStatusUseCase {
	Future<Result<void>> execute(UpdateMyWordStatusInputData input);
}
