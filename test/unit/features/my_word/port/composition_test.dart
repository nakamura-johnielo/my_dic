import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:my_dic/core/infrastructure/database/drift/database_provider.dart';
import 'package:my_dic/features/my_word/port/composition.dart';
import 'package:my_dic/features/sync/port/outbox_writer.dart';
import 'package:my_dic/features/sync/port/remote_mutation_executor.dart';
import 'package:my_dic/features/sync/port/sync_handler_runtime.dart';

class _OutboxWriter extends Mock implements OutboxWriter {}

class _Firestore extends Mock implements FirebaseFirestore {}

class _RemoteMutationExecutor extends Mock implements RemoteMutationExecutor {}

class _Runtime extends Mock implements SyncHandlerRuntime {}

void main() {
  test('composition creates the complete MyWord port set from opaque services',
      () {
    final database = DatabaseProvider.forTesting(NativeDatabase.memory());
    addTearDown(database.close);
    final outbox = _OutboxWriter();

    final ports = createMyWordPorts(<T>(dependency) {
      switch (dependency) {
        case MyWordDependency.database:
          return database as T;
        case MyWordDependency.outboxWriter:
          return outbox as T;
      }
    });

    expect(ports.reader, same(ports.commands));
    expect(ports.statusCommands, same(ports.commands));
    expect(ports.guestMigration, isNotNull);
  });

  test('both dataset factories construct handlers from their opaque runtime',
      () {
    final database = DatabaseProvider.forTesting(NativeDatabase.memory());
    addTearDown(database.close);
    final firestore = _Firestore();
    final executor = _RemoteMutationExecutor();
    final runtime = _Runtime();

    T read<T>(Object dependency) => switch (dependency) {
          MyWordSyncDependency.database => database as T,
          MyWordSyncDependency.firestore => firestore as T,
          MyWordSyncDependency.remoteMutationExecutor => executor as T,
          _ => throw ArgumentError.value(dependency, 'dependency'),
        };

    expect(createMyWordDatasetSyncHandler(read, runtime: runtime), isNotNull);
    expect(
      createMyWordStatusDatasetSyncHandler(read, runtime: runtime),
      isNotNull,
    );
  });
}
