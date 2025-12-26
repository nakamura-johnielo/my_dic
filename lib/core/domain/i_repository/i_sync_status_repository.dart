
import 'package:my_dic/core/shared/utils/result.dart';

abstract class ISyncStatusRepository {
  Future<Result<DateTime?>> getLastSyncDate();
  Future<Result<void>> updateSyncDate(DateTime date);

}