import 'package:flutter_test/flutter_test.dart';
import 'package:my_dic/features/sync/port/model/sync_mutation.dart';
import 'package:my_dic/features/sync/port/sync_queue.dart';
import '../../../helpers/sync/fake_sync_queue.dart';
import '../../../support/contracts/sync_queue_contract.dart';

class _Harness implements SyncQueueHarness {
  final FakeSyncQueue fake = FakeSyncQueue();
  @override
  SyncQueue get queue => fake;
  @override
  Future<void> enqueue(SyncMutation mutation) async => fake.enqueue(mutation);
  @override
  Future<void> close() async {}
}

void main() => syncQueueContract('fake', () async => _Harness());
