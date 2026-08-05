import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:my_dic/core/infrastructure/database/drift/database_provider.dart';
import 'package:my_dic/features/sync/application/model/sync_mutation.dart';
import 'package:my_dic/features/sync/application/port/sync_queue.dart';
import 'package:my_dic/features/sync/infrastructure/persistence/drift/drift_outbox_writer.dart';
import 'package:my_dic/features/sync/infrastructure/persistence/drift/drift_sync_queue.dart';
import '../../../support/contracts/sync_queue_contract.dart';

class _Harness implements SyncQueueHarness {
  _Harness(this.database)
      : writer = DriftOutboxWriter(database, clock: () => DateTime.utc(2026)),
        driftQueue = DriftSyncQueue(database);
  final DatabaseProvider database;
  final DriftOutboxWriter writer;
  final DriftSyncQueue driftQueue;
  @override
  SyncQueue get queue => driftQueue;
  @override
  Future<void> enqueue(SyncMutation mutation) => writer.enqueue(mutation);
  @override
  Future<void> close() => database.close();
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  syncQueueContract(
      'drift',
      () async =>
          _Harness(DatabaseProvider.forTesting(NativeDatabase.memory())));
}
