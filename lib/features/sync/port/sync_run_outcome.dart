/// 要求された Sync 実行の UI／ワークフローで安全な結果です。
///
/// [retryScheduled] が返る前に、永続的な再試行はすでに保存されています。したがって、
/// [nonRetryableFailure] とは異なります。
enum SyncRunOutcome {
  success,
  retryScheduled,
  nonRetryableFailure,
  cancelled,
}
