import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:my_dic/core/infrastructure/database/drift/database_provider.dart';
import 'package:my_dic/core/port/firebase_account_nested_document_gateway.dart';
import 'package:my_dic/core/shared/consts/account_scope.dart';
import 'package:my_dic/features/my_word/port/command.dart';
import 'package:my_dic/features/my_word/port/composition.dart';
import 'package:my_dic/features/my_word/port/guest_migration.dart';
import 'package:my_dic/features/sync/port/cancellation_token.dart';
import 'package:my_dic/features/sync/port/dataset_sync_gateway.dart';
import 'package:my_dic/features/sync/port/model/dataset_sync_result.dart';
import 'package:my_dic/features/sync/port/model/sync_context.dart';
import 'package:my_dic/features/sync/port/model/sync_mutation.dart';
import 'package:my_dic/features/sync/port/outbox_writer.dart';
import 'package:my_dic/features/sync/port/remote_mutation_executor.dart';
import 'package:my_dic/features/sync/port/sync_dataset.dart';
import 'package:my_dic/features/sync/port/sync_handler_runtime.dart';

class _OutboxWriter extends Mock implements OutboxWriter {}

class _RemoteDocuments extends Mock
    implements FirebaseAccountNestedUpdatedDocumentGateway {}

class _RemoteMutationExecutor extends Mock implements RemoteMutationExecutor {}

final class _RecordingRuntime implements SyncHandlerRuntime {
  final adapters = <DatasetSyncGateway>[];

  @override
  Future<DatasetSyncResult> run(
    SyncContext context,
    DatasetSyncGateway adapter,
  ) async {
    adapters.add(adapter);
    return const DatasetSyncResult.success(pushedCount: 0, pulledCount: 0);
  }
}

void main() {
  setUpAll(() {
    registerFallbackValue(SyncMutation(
      mutationId: 'fallback',
      accountId: 'fallback',
      dataset: SyncDataset.myWords,
      entityId: 'fallback',
      operation: SyncMutationOperation.patch,
      payload: const {},
      fieldMask: const [],
      localRevision: 0,
      clientUpdatedAt: DateTime.utc(2026),
    ));
  });

  test('composition preserves the shared application port identities', () {
    final database = DatabaseProvider.forTesting(NativeDatabase.memory());
    addTearDown(database.close);
    final outbox = _OutboxWriter();

    final ports = createMyWordPorts(
      dependencies: MyWordDependencies(
        database: database,
        outboxWriter: outbox,
      ),
    );

    expect(ports.reader, same(ports.commands));
    expect(ports.statusCommands, same(ports.commands));
  });

  test('guest migration uses the composed database and outbox writer',
      () async {
    final database = DatabaseProvider.forTesting(NativeDatabase.memory());
    addTearDown(database.close);
    final outbox = _OutboxWriter();
    when(() => outbox.enqueue(any())).thenAnswer((_) async {});

    final ports = createMyWordPorts(
      dependencies: MyWordDependencies(
        database: database,
        outboxWriter: outbox,
      ),
    );

    final registered = await ports.commands.register(
      const RegisterMyWordCommand(
        headword: 'hola',
        description: 'greeting',
        accountScope: guestAccountScope,
      ),
    );
    expect(registered.isSuccess, isTrue);
    expect(
      await ports.guestMigration.countGuestRows(),
      isA<MyWordGuestRowCounts>()
          .having((counts) => counts.words, 'words', 1)
          .having((counts) => counts.statuses, 'statuses', 0),
    );

    clearInteractions(outbox);
    await ports.guestMigration.migrateGuestRows(
      accountId: 'account-a',
      migrationId: 'migration-a',
      clock: () => DateTime.utc(2026, 8, 13),
    );

    final mutation = verify(() => outbox.enqueue(captureAny())).captured.single
        as SyncMutation;
    expect(mutation.accountId, 'account-a');
    expect(mutation.dataset, SyncDataset.myWords);
    expect((await ports.guestMigration.countGuestRows()).words, 0);
  });

  test('dataset factories use the requested services and the same runtime',
      () async {
    final database = DatabaseProvider.forTesting(NativeDatabase.memory());
    addTearDown(database.close);
    final remoteDocuments = _RemoteDocuments();
    final executor = _RemoteMutationExecutor();
    final runtime = _RecordingRuntime();
    final dependencies = MyWordSyncDependencies(
      database: database,
      remoteDocuments: remoteDocuments,
      remoteMutationExecutor: executor,
    );

    final myWords = createMyWordDatasetSyncHandler(
      dependencies: dependencies,
      runtime: runtime,
    );
    final statuses = createMyWordStatusDatasetSyncHandler(
      dependencies: dependencies,
      runtime: runtime,
    );

    expect(myWords.dataset, SyncDataset.myWords);
    expect(myWords.dataset.stableId, 'my_words');
    expect(statuses.dataset, SyncDataset.myWordStatus);
    expect(statuses.dataset.stableId, 'my_word_status');
    final context = SyncContext(
      accountId: 'account-a',
      sessionEpoch: 1,
      reason: 'composition characterization',
      cancellation: CancellationToken(),
    );
    await myWords.run(context);
    await statuses.run(context);

    expect(runtime.adapters, hasLength(2));
    expect(runtime.adapters[0].dataset, SyncDataset.myWords);
    expect(runtime.adapters[1].dataset, SyncDataset.myWordStatus);
  });
}
