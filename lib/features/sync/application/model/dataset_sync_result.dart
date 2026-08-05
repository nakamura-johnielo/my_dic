import 'package:my_dic/features/sync/application/model/sync_cursor.dart';

sealed class DatasetSyncResult {
  const DatasetSyncResult();
  const factory DatasetSyncResult.success({
    required int pushedCount,
    required int pulledCount,
    SyncCursor? cursor,
  }) = DatasetSyncSuccess;
  const factory DatasetSyncResult.skipped(String reason) = DatasetSyncSkipped;
  const factory DatasetSyncResult.failed({
    required String errorCode,
    required bool retryable,
    required bool cursorUnchanged,
  }) = DatasetSyncFailed;
  const factory DatasetSyncResult.cancelled(String reason) =
      DatasetSyncCancelled;
}

class DatasetSyncSuccess extends DatasetSyncResult {
  const DatasetSyncSuccess(
      {required this.pushedCount, required this.pulledCount, this.cursor});
  final int pushedCount;
  final int pulledCount;
  final SyncCursor? cursor;
}

class DatasetSyncSkipped extends DatasetSyncResult {
  const DatasetSyncSkipped(this.reason);
  final String reason;
}

class DatasetSyncFailed extends DatasetSyncResult {
  const DatasetSyncFailed(
      {required this.errorCode,
      required this.retryable,
      required this.cursorUnchanged});
  final String errorCode;
  final bool retryable;
  final bool cursorUnchanged;
}

class DatasetSyncCancelled extends DatasetSyncResult {
  const DatasetSyncCancelled(this.reason);
  final String reason;
}
