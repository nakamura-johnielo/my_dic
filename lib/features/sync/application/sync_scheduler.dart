import 'package:my_dic/features/sync/application/model/sync_context.dart';
import 'package:my_dic/features/sync/application/model/sync_report.dart';
import 'package:my_dic/features/sync/application/sync_engine.dart';

/// Lifecycle adapters invoke this class only. It deliberately contains no
/// Firebase, Drift, listener, or feature-specific behaviour.
class SyncScheduler {
  SyncScheduler(this._engine);
  final SyncEngine _engine;

  Future<SyncReport> foreground(SyncContext context) =>
      _engine.runOnce(context);
}
