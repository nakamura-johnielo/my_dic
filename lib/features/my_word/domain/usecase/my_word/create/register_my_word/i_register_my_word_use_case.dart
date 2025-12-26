import 'package:my_dic/core/shared/utils/result.dart';
import 'package:my_dic/features/my_word/domain/usecase/my_word/create/register_my_word/register_my_word_input_data.dart';

abstract class IRegisterMyWordUseCase {
  Future<Result<int>> execute(RegisterMyWordInputData input);
}
