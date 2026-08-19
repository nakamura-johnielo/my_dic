/// アカウントの次回永続化アウトボックス再試行をスケジュールします。
///
/// 再試行時刻の信頼できる情報源はキューのままです。実装はアカウントごとに最大 1 つの
/// 起床を保持し、スケジューリング状態を永続化しません。
abstract interface class SyncRetryWakeup {
  void arm({
    required String accountId,
    required DateTime dueAt,
    required void Function() onDue,
  });

  void cancel(String accountId);
  void dispose();
}
