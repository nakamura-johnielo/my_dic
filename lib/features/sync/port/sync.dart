/// Sync ワークフローの唯一のビジネス向け公開面です。
///
/// データセット実装は `dataset_contract.dart` を、アプリ構成は `composition.dart` を使用します。
/// どちらの技術的な境界もここでは再エクスポートしません。
export 'cancellation_token.dart';
export 'model/sync_context.dart';
export 'model/sync_mutation.dart';
export 'outbox_writer.dart';
export 'session_fence.dart';
export 'sync_reason_codes.dart';
export 'sync_run_outcome.dart';
export 'sync_runner.dart';
