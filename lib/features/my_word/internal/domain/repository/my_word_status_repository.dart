import 'package:my_dic/core/shared/utils/result.dart';
import 'package:my_dic/features/my_word/internal/domain/entity/my_word_status.dart';
import 'update_my_word_status_record.dart';

abstract interface class IMyWordStatusRepository {
  // Local methods
  Future<Result<void>> updateStatus(UpdateMyWordStatusInputData input);
  Stream<MyWordStatus> watchStatus(String wordId, {required String accountId});
}
