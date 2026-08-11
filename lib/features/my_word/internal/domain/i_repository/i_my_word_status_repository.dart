import 'package:my_dic/core/shared/utils/result.dart';
import 'package:my_dic/features/my_word/internal/domain/entity/my_word_status.dart';
import 'package:my_dic/features/my_word/internal/domain/inputData/my_word_status/update_my_word_status_repository_input_data.dart';

abstract class IMyWordStatusRepository {
  // Local methods
  Future<Result<void>> updateStatus(
      UpdateMyWordStatusRepositoryInputData input);
  Stream<MyWordStatus> watchStatus(String wordId, {required String accountId});
}
