import 'package:my_dic/core/shared/utils/result.dart';
import 'package:my_dic/features/my_word/domain/usecase/my_word/delete/delete_my_word/delete_my_word_input_data.dart';

abstract class IDeleteMyWordUseCase {
  Future<Result<void>> execute(DeleteMyWordInputData input);
}
