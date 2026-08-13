import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:drift/native.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:my_dic/app/bootstrap/firebase_providers.dart';
import 'package:my_dic/app/bootstrap/my_word_composition.dart';
import 'package:my_dic/app/bootstrap/sync_infrastructure_providers.dart';
import 'package:my_dic/core/di/data/data_di.dart';
import 'package:my_dic/core/infrastructure/database/drift/database_provider.dart';
import 'package:my_dic/features/my_word/port/command.dart';
import 'package:my_dic/features/my_word/port/composition.dart';
import 'package:my_dic/features/my_word/port/guest_migration.dart';
import 'package:my_dic/features/my_word/port/query.dart';
import 'package:my_dic/features/sync/port/dataset_sync_adapter.dart';
import 'package:my_dic/features/sync/port/dataset_sync_handler.dart';
import 'package:my_dic/features/sync/port/model/dataset_sync_result.dart';
import 'package:my_dic/features/sync/port/model/sync_context.dart';
import 'package:my_dic/features/sync/port/outbox_writer.dart';
import 'package:my_dic/features/sync/port/remote_mutation_executor.dart';
import 'package:my_dic/features/sync/port/sync_dataset.dart';
import 'package:my_dic/features/sync/port/sync_handler_runtime.dart';

final class _OutboxWriter extends Mock implements IOutboxWriter {}

final class _Firestore extends Mock implements FirebaseFirestore {}

final class _RemoteMutationExecutor extends Mock
    implements IRemoteMutationExecutor {}

final class _Runtime implements ISyncHandlerRuntime {
  final adapters = <IDatasetSyncAdapter>[];

  @override
  Future<DatasetSyncResult> run(
    SyncContext context,
    IDatasetSyncAdapter adapter,
  ) async {
    adapters.add(adapter);
    return const DatasetSyncResult.success(pushedCount: 0, pulledCount: 0);
  }
}

final class _Query extends Mock implements MyWordQueryPort {}

final class _Commands extends Mock implements MyWordCommandPort {}

final class _StatusCommands extends Mock implements MyWordStatusCommandPort {}

final class _GuestMigration extends Mock implements MyWordGuestMigrationPort {}

final class _Handler implements IDatasetSyncHandler {
  const _Handler(this.dataset);

  @override
  final SyncDataset dataset;

  @override
  Future<DatasetSyncResult> run(SyncContext context) async =>
      const DatasetSyncResult.success(pushedCount: 0, pulledCount: 0);
}

void main() {
  test('builds and refreshes all completed MyWord providers from overrides',
      () async {
    final database = DatabaseProvider.forTesting(NativeDatabase.memory());
    final runtime = _Runtime();
    final container = ProviderContainer(overrides: [
      databaseProvider.overrideWithValue(database),
      driftOutboxWriterProvider.overrideWithValue(_OutboxWriter()),
      firestoreDBProvider.overrideWithValue(_Firestore()),
      remoteMutationExecutorProvider.overrideWithValue(
        _RemoteMutationExecutor(),
      ),
      syncHandlerRuntimeProvider.overrideWithValue(runtime),
    ]);
    addTearDown(() async {
      container.dispose();
      await database.close();
    });

    final ports = container.read(myWordPortsProvider);
    final myWords = container.read(myWordDatasetSyncHandlerProvider);
    final statuses = container.read(myWordStatusDatasetSyncHandlerProvider);

    expect(ports.reader, same(ports.commands));
    expect(ports.statusCommands, same(ports.commands));
    expect(myWords.dataset, SyncDataset.myWords);
    expect(statuses.dataset, SyncDataset.myWordStatus);

    expect(container.refresh(myWordPortsProvider), isNot(same(ports)));
    expect(
      container.refresh(myWordDatasetSyncHandlerProvider),
      isNot(same(myWords)),
    );
    expect(
      container.refresh(myWordStatusDatasetSyncHandlerProvider),
      isNot(same(statuses)),
    );
  });

  test('allows completed capabilities to be overridden by consumers', () {
    final ports = MyWordPorts(
      reader: _Query(),
      commands: _Commands(),
      statusCommands: _StatusCommands(),
      guestMigration: _GuestMigration(),
    );
    const myWords = _Handler(SyncDataset.myWords);
    const statuses = _Handler(SyncDataset.myWordStatus);
    final container = ProviderContainer(overrides: [
      myWordPortsProvider.overrideWithValue(ports),
      myWordDatasetSyncHandlerProvider.overrideWithValue(myWords),
      myWordStatusDatasetSyncHandlerProvider.overrideWithValue(statuses),
    ]);
    addTearDown(container.dispose);

    expect(container.read(myWordPortsProvider), same(ports));
    expect(container.read(myWordDatasetSyncHandlerProvider), same(myWords));
    expect(
      container.read(myWordStatusDatasetSyncHandlerProvider),
      same(statuses),
    );
  });
}
