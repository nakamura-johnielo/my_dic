import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:my_dic/core/infrastructure/database/drift/daos/esp_jpn/esp_jpn_word_status_dao.dart';
import 'package:my_dic/core/infrastructure/database/drift/daos/jpn_esp/jpn_esp_word_status_dao.dart';
import 'package:my_dic/core/infrastructure/database/drift/database_provider.dart';
import 'package:my_dic/core/infrastructure/datasource/jpn_esp_word_status/i_remote_jpn_esp_word_status_data_source.dart';
import 'package:my_dic/core/infrastructure/datasource/jpn_esp_word_status/jpn_esp_drift_word_status_data_source.dart';
import 'package:my_dic/core/infrastructure/datasource/word_status/drift_word_status_data_source.dart';
import 'package:my_dic/core/infrastructure/datasource/word_status/i_remote_word_status_data_source.dart';
import 'package:my_dic/core/shared/enums/sync_dataset.dart';
import 'package:my_dic/features/esp_jpn_word_status/data/sync/esp_jpn_word_status_sync_handler.dart';
import 'package:my_dic/features/esp_jpn_word_status/data/wordStatusEntity.dart';
import 'package:my_dic/features/jpn_esp_word_status/data/jpn_esp_word_status_entity.dart';
import 'package:my_dic/features/jpn_esp_word_status/data/sync/jpn_esp_word_status_sync_handler.dart';
import 'package:my_dic/features/sync/application/cancellation_token.dart';
import 'package:my_dic/features/sync/application/model/dataset_sync_result.dart';
import 'package:my_dic/features/sync/application/model/sync_context.dart';
import 'package:my_dic/features/sync/application/model/sync_mutation.dart';
import 'package:my_dic/features/sync/application/port/dataset_sync_handler.dart';
import 'package:my_dic/features/sync/infrastructure/persistence/drift/drift_sync_checkpoint_store.dart';

import '../../../helpers/sync/fake_sync_queue.dart';

class _MockEspRemote extends Mock implements IRemoteWordStatusDataSource {}

class _MockJpnEspRemote extends Mock
    implements IRemoteJpnEspWordStatusDataSource {}

const _accountId = 'account-a';

SyncMutation _mutation({
  required SyncDataset dataset,
  required List<String> fieldMask,
  required Map<String, Object?> payload,
  int localRevision = 1,
  String entityId = '1',
}) =>
    SyncMutation(
      mutationId: 'mutation-$entityId-${fieldMask.join('-')}',
      accountId: _accountId,
      dataset: dataset,
      entityId: entityId,
      operation: SyncMutationOperation.patch,
      payload: payload,
      fieldMask: fieldMask,
      localRevision: localRevision,
    );

abstract interface class _HandlerFixture {
  DatasetSyncHandler get handler;
  FakeSyncQueue get queue;
  SyncDataset get dataset;
  Future<void> close();
  Future<bool> exists(int wordId);
  Future<({bool? learned, bool? bookmarked, bool? hasNote})> read(int wordId);
  Future<void> seed(int wordId,
      {required bool isLearned,
      required bool isBookmarked,
      required bool hasNote});
}

class _EspJpnFixture implements _HandlerFixture {
  _EspJpnFixture._(
      this._database, this.handler, this.queue, this._remote, this._dao);

  final DatabaseProvider _database;
  @override
  final EspJpnWordStatusSyncHandler handler;
  @override
  final FakeSyncQueue queue;
  final _MockEspRemote _remote;
  final EspJpnWordStatusDao _dao;

  @override
  final SyncDataset dataset = SyncDataset.espJpnWordStatus;

  IRemoteWordStatusDataSource get remote => _remote;

  static Future<_EspJpnFixture> create() async {
    final database = DatabaseProvider.forTesting(NativeDatabase.memory());
    final dao = EspJpnWordStatusDao(database);
    final local = DriftWordStatusDataSource(dao);
    final remote = _MockEspRemote();
    final queue = FakeSyncQueue();
    final checkpointStore = DriftSyncCheckpointStore(database);
    final handler = EspJpnWordStatusSyncHandler(
      queue: queue,
      checkpointStore: checkpointStore,
      local: local,
      remote: remote,
      clock: () => DateTime.utc(2026, 8, 6),
    );
    return _EspJpnFixture._(database, handler, queue, remote, dao);
  }

  @override
  Future<void> close() => _database.close();

  @override
  Future<bool> exists(int wordId) => _dao.exist(wordId, _accountId);

  @override
  Future<({bool? learned, bool? bookmarked, bool? hasNote})> read(
      int wordId) async {
    final row = await _dao.getStatusById(wordId, _accountId);
    if (row == null) return (learned: null, bookmarked: null, hasNote: null);
    return (
      learned: row.isLearned == 1,
      bookmarked: row.isBookmarked == 1,
      hasNote: row.hasNote == 1,
    );
  }

  @override
  Future<void> seed(int wordId,
      {required bool isLearned,
      required bool isBookmarked,
      required bool hasNote}) {
    return _dao.applyStatusPatch(wordId, isLearned, isBookmarked, hasNote,
        DateTime.utc(2026, 8, 1).toIso8601String(), _accountId);
  }
}

class _JpnEspFixture implements _HandlerFixture {
  _JpnEspFixture._(
      this._database, this.handler, this.queue, this._remote, this._dao);

  final DatabaseProvider _database;
  @override
  final JpnEspWordStatusSyncHandler handler;
  @override
  final FakeSyncQueue queue;
  final _MockJpnEspRemote _remote;
  final JpnEspWordStatusDao _dao;

  @override
  final SyncDataset dataset = SyncDataset.jpnEspWordStatus;

  IRemoteJpnEspWordStatusDataSource get remote => _remote;

  static Future<_JpnEspFixture> create() async {
    final database = DatabaseProvider.forTesting(NativeDatabase.memory());
    final dao = JpnEspWordStatusDao(database);
    final local = JpnEspDriftWordStatusDataSource(dao);
    final remote = _MockJpnEspRemote();
    final queue = FakeSyncQueue();
    final checkpointStore = DriftSyncCheckpointStore(database);
    final handler = JpnEspWordStatusSyncHandler(
      queue: queue,
      checkpointStore: checkpointStore,
      local: local,
      remote: remote,
      clock: () => DateTime.utc(2026, 8, 6),
    );
    return _JpnEspFixture._(database, handler, queue, remote, dao);
  }

  @override
  Future<void> close() => _database.close();

  @override
  Future<bool> exists(int wordId) => _dao.exist(wordId, _accountId);

  @override
  Future<({bool? learned, bool? bookmarked, bool? hasNote})> read(
      int wordId) async {
    final row = await _dao.getStatusById(wordId, _accountId);
    if (row == null) return (learned: null, bookmarked: null, hasNote: null);
    return (
      learned: row.isLearned == 1,
      bookmarked: row.isBookmarked == 1,
      hasNote: row.hasNote == 1,
    );
  }

  @override
  Future<void> seed(int wordId,
      {required bool isLearned,
      required bool isBookmarked,
      required bool hasNote}) {
    return _dao.applyStatusPatch(wordId, isLearned, isBookmarked, hasNote,
        DateTime.utc(2026, 8, 1).toIso8601String(), _accountId);
  }
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(() {
    registerFallbackValue(<String, Object?>{});
    registerFallbackValue(<String>[]);
  });

  final fixtures = <String, Future<_HandlerFixture> Function()>{
    'Esp-Jpn': _EspJpnFixture.create,
    'Jpn-Esp': _JpnEspFixture.create,
  };

  for (final fixtureEntry in fixtures.entries) {
    group('${fixtureEntry.key} word status sync handler', () {
      late _HandlerFixture fixture;

      setUp(() async {
        fixture = await fixtureEntry.value();
      });

      tearDown(() => fixture.close());

      test('pushes a leased mutation as a field-mask patch and acks it',
          () async {
        fixture.queue.enqueue(_mutation(
          dataset: fixture.dataset,
          fieldMask: const ['isBookmarked'],
          payload: const {'isBookmarked': true},
        ));
        if (fixture is _EspJpnFixture) {
          final espJpn = fixture as _EspJpnFixture;
          when(() => espJpn.remote.getWordStatusById(_accountId, 1))
              .thenAnswer((_) async => null);
          when(() => espJpn.remote.patchWordStatus(
                _accountId,
                1,
                any(),
                any(),
                isNew: any(named: 'isNew'),
              )).thenAnswer((_) async {});
          when(() => espJpn.remote.getWordStatusAfter(_accountId, any()))
              .thenAnswer((_) async => const []);
        } else {
          final jpnEsp = fixture as _JpnEspFixture;
          when(() => jpnEsp.remote.getWordStatusById(_accountId, 1))
              .thenAnswer((_) async => null);
          when(() => jpnEsp.remote.patchWordStatus(
                _accountId,
                1,
                any(),
                any(),
                isNew: any(named: 'isNew'),
              )).thenAnswer((_) async {});
          when(() => jpnEsp.remote.getWordStatusAfter(_accountId, any()))
              .thenAnswer((_) async => const []);
        }

        final result = await fixture.handler.run(SyncContext(
          accountId: _accountId,
          sessionEpoch: 1,
          reason: 'test',
          cancellation: CancellationToken(),
        ));

        expect(result, isA<DatasetSyncSuccess>());
        expect((result as DatasetSyncSuccess).pushedCount, 1);
        expect(fixture.queue.pending, isEmpty);
        expect(fixture.queue.leased, isEmpty);
      });

      test('a retryable remote failure re-queues the mutation as pending',
          () async {
        fixture.queue.enqueue(_mutation(
          dataset: fixture.dataset,
          fieldMask: const ['isLearned'],
          payload: const {'isLearned': true},
        ));
        if (fixture is _EspJpnFixture) {
          final espJpn = fixture as _EspJpnFixture;
          when(() => espJpn.remote.getWordStatusById(_accountId, 1))
              .thenThrow(Exception('unavailable'));
          when(() => espJpn.remote.getWordStatusAfter(_accountId, any()))
              .thenAnswer((_) async => const []);
        } else {
          final jpnEsp = fixture as _JpnEspFixture;
          when(() => jpnEsp.remote.getWordStatusById(_accountId, 1))
              .thenThrow(Exception('unavailable'));
          when(() => jpnEsp.remote.getWordStatusAfter(_accountId, any()))
              .thenAnswer((_) async => const []);
        }

        final result = await fixture.handler.run(SyncContext(
          accountId: _accountId,
          sessionEpoch: 1,
          reason: 'test',
          cancellation: CancellationToken(),
        ));

        expect(result, isA<DatasetSyncFailed>());
        expect((result as DatasetSyncFailed).retryable, isTrue);
        expect(fixture.queue.pending, hasLength(1));
        expect(fixture.queue.deadLetters, isEmpty);
      });

      test('an invalid payload failure dead-letters the mutation', () async {
        fixture.queue.enqueue(_mutation(
          dataset: fixture.dataset,
          fieldMask: const ['isLearned'],
          payload: const {'isLearned': true},
        ));
        if (fixture is _EspJpnFixture) {
          final espJpn = fixture as _EspJpnFixture;
          when(() => espJpn.remote.getWordStatusById(_accountId, 1))
              .thenThrow(Exception('invalid-argument'));
          when(() => espJpn.remote.getWordStatusAfter(_accountId, any()))
              .thenAnswer((_) async => const []);
        } else {
          final jpnEsp = fixture as _JpnEspFixture;
          when(() => jpnEsp.remote.getWordStatusById(_accountId, 1))
              .thenThrow(Exception('invalid-argument'));
          when(() => jpnEsp.remote.getWordStatusAfter(_accountId, any()))
              .thenAnswer((_) async => const []);
        }

        final result = await fixture.handler.run(SyncContext(
          accountId: _accountId,
          sessionEpoch: 1,
          reason: 'test',
          cancellation: CancellationToken(),
        ));

        expect(result, isA<DatasetSyncFailed>());
        expect((result as DatasetSyncFailed).retryable, isFalse);
        expect(fixture.queue.pending, isEmpty);
        expect(fixture.queue.deadLetters, hasLength(1));
      });

      test('pulled remote fields are applied and the checkpoint advances',
          () async {
        final updatedAt = DateTime.utc(2026, 8, 5, 12);
        if (fixture is _EspJpnFixture) {
          final espJpn = fixture as _EspJpnFixture;
          when(() => espJpn.remote.getWordStatusAfter(_accountId, any()))
              .thenAnswer((_) async => [
                    WordStatusDTO(
                      wordId: 2,
                      isLearned: 1,
                      isBookmarked: 0,
                      hasNote: 0,
                      createdAt: updatedAt,
                      updatedAt: updatedAt,
                    ),
                  ]);
        } else {
          final jpnEsp = fixture as _JpnEspFixture;
          when(() => jpnEsp.remote.getWordStatusAfter(_accountId, any()))
              .thenAnswer((_) async => [
                    JpnEspWordStatusDTO(
                      wordId: 2,
                      isLearned: 1,
                      isBookmarked: 0,
                      hasNote: 0,
                      createdAt: updatedAt,
                      updatedAt: updatedAt,
                    ),
                  ]);
        }

        final result = await fixture.handler.run(SyncContext(
          accountId: _accountId,
          sessionEpoch: 1,
          reason: 'test',
          cancellation: CancellationToken(),
        ));

        expect(result, isA<DatasetSyncSuccess>());
        expect((result as DatasetSyncSuccess).pulledCount, 1);
        expect(await fixture.exists(2), isTrue);
        final row = await fixture.read(2);
        expect(row.learned, isTrue);
        expect(row.bookmarked, isFalse);
        expect(fixture.queue.pending, isEmpty,
            reason: 'applying a remote snapshot must not enqueue an outbox '
                'mutation');
      });

      test(
          'a pulled field with an in-flight local mutation is not overwritten',
          () async {
        await fixture.seed(3,
            isLearned: false, isBookmarked: true, hasNote: false);
        fixture.queue.enqueue(_mutation(
          dataset: fixture.dataset,
          entityId: '3',
          fieldMask: const ['isBookmarked'],
          payload: const {'isBookmarked': true},
        ));
        // Simulate the mutation already being leased by an earlier/concurrent
        // push attempt, so this run's own push phase has nothing new to lease
        // for entity 3 while peekPending still reports it as in-flight.
        await fixture.queue.leasePending(
          accountId: _accountId,
          dataset: fixture.dataset,
          limit: 10,
          now: DateTime.utc(2026, 8, 6),
          leaseDuration: const Duration(minutes: 5),
        );
        final updatedAt = DateTime.utc(2026, 8, 5, 12);
        if (fixture is _EspJpnFixture) {
          final espJpn = fixture as _EspJpnFixture;
          when(() => espJpn.remote.getWordStatusAfter(_accountId, any()))
              .thenAnswer((_) async => [
                    WordStatusDTO(
                      wordId: 3,
                      isLearned: 1,
                      isBookmarked: 0,
                      hasNote: 1,
                      createdAt: updatedAt,
                      updatedAt: updatedAt,
                    ),
                  ]);
        } else {
          final jpnEsp = fixture as _JpnEspFixture;
          when(() => jpnEsp.remote.getWordStatusAfter(_accountId, any()))
              .thenAnswer((_) async => [
                    JpnEspWordStatusDTO(
                      wordId: 3,
                      isLearned: 1,
                      isBookmarked: 0,
                      hasNote: 1,
                      createdAt: updatedAt,
                      updatedAt: updatedAt,
                    ),
                  ]);
        }

        await fixture.handler.run(SyncContext(
          accountId: _accountId,
          sessionEpoch: 1,
          reason: 'test',
          cancellation: CancellationToken(),
        ));

        final row = await fixture.read(3);
        // isLearned/hasNote come from the merged remote snapshot; isBookmarked
        // keeps the not-yet-pushed local `true` instead of the remote's stale
        // `false`.
        expect(row.learned, isTrue);
        expect(row.hasNote, isTrue);
        expect(row.bookmarked, isTrue);
      });
    });
  }
}
