import 'dart:convert';

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
import 'package:my_dic/core/shared/value_objects/field_update.dart';
import 'package:my_dic/features/esp_jpn_word_status/data/wordstatus_repository.dart';
import 'package:my_dic/features/esp_jpn_word_status/domain/usecase/update_status/update_status_repository_input_data.dart';
import 'package:my_dic/features/jpn_esp_word_status/data/jpn_esp_word_status_repository.dart';
import 'package:my_dic/features/jpn_esp_word_status/domain/usecase/update_jpn_esp_status/update_jpn_esp_status_repository_input_data.dart';
import 'package:my_dic/features/sync/infrastructure/persistence/drift/drift_outbox_writer.dart';

class _MockEspRemoteDataSource extends Mock
    implements IRemoteWordStatusDataSource {}

class _MockJpnEspRemoteDataSource extends Mock
    implements IRemoteJpnEspWordStatusDataSource {}

abstract interface class _OutboxFixture {
  SyncDataset get dataset;
  DatabaseProvider get database;
  Future<void> apply({
    FieldUpdate<bool> learned,
    FieldUpdate<bool> bookmarked,
    FieldUpdate<bool> hasNote,
    required String? accountId,
  });
  Future<void> close();
}

class _EspJpnOutboxFixture implements _OutboxFixture {
  _EspJpnOutboxFixture._(this._database, this._repository);

  final DatabaseProvider _database;
  final WordStatusRepository _repository;

  @override
  final SyncDataset dataset = SyncDataset.espJpnWordStatus;

  @override
  DatabaseProvider get database => _database;

  static Future<_EspJpnOutboxFixture> create() async {
    final database = DatabaseProvider.forTesting(NativeDatabase.memory());
    final local = DriftWordStatusDataSource(EspJpnWordStatusDao(database));
    final writer = DriftOutboxWriter(database, clock: () => DateTime.utc(2026));
    return _EspJpnOutboxFixture._(
      database,
      WordStatusRepository(_MockEspRemoteDataSource(), local, writer),
    );
  }

  @override
  Future<void> apply({
    FieldUpdate<bool> learned = const FieldUpdate.unchanged(),
    FieldUpdate<bool> bookmarked = const FieldUpdate.unchanged(),
    FieldUpdate<bool> hasNote = const FieldUpdate.unchanged(),
    required String? accountId,
  }) async {
    final result = await _repository.updateLocalWordStatus(
      UpdateStatusRepositoryInputData(
        wordId: 1,
        isLearned: learned,
        isBookmarked: bookmarked,
        hasNote: hasNote,
      ),
      DateTime.utc(2026, 8, 5),
      accountId: accountId,
    );
    expect(result.isSuccess, isTrue);
  }

  @override
  Future<void> close() => _database.close();
}

class _JpnEspOutboxFixture implements _OutboxFixture {
  _JpnEspOutboxFixture._(this._database, this._repository);

  final DatabaseProvider _database;
  final JpnEspWordStatusRepository _repository;

  @override
  final SyncDataset dataset = SyncDataset.jpnEspWordStatus;

  @override
  DatabaseProvider get database => _database;

  static Future<_JpnEspOutboxFixture> create() async {
    final database = DatabaseProvider.forTesting(NativeDatabase.memory());
    final local =
        JpnEspDriftWordStatusDataSource(JpnEspWordStatusDao(database));
    final writer = DriftOutboxWriter(database, clock: () => DateTime.utc(2026));
    return _JpnEspOutboxFixture._(
      database,
      JpnEspWordStatusRepository(_MockJpnEspRemoteDataSource(), local, writer),
    );
  }

  @override
  Future<void> apply({
    FieldUpdate<bool> learned = const FieldUpdate.unchanged(),
    FieldUpdate<bool> bookmarked = const FieldUpdate.unchanged(),
    FieldUpdate<bool> hasNote = const FieldUpdate.unchanged(),
    required String? accountId,
  }) async {
    final result = await _repository.updateLocalWordStatus(
      UpdateJpnEspStatusRepositoryInputData(
        wordId: 1,
        isLearned: learned,
        isBookmarked: bookmarked,
        hasNote: hasNote,
      ),
      DateTime.utc(2026, 8, 5),
      accountId: accountId,
    );
    expect(result.isSuccess, isTrue);
  }

  @override
  Future<void> close() => _database.close();
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  final fixtures = <String, Future<_OutboxFixture> Function()>{
    'Esp-Jpn': _EspJpnOutboxFixture.create,
    'Jpn-Esp': _JpnEspOutboxFixture.create,
  };

  for (final fixtureEntry in fixtures.entries) {
    group('${fixtureEntry.key} outbox enqueue on local write', () {
      late _OutboxFixture fixture;

      setUp(() async {
        fixture = await fixtureEntry.value();
      });

      tearDown(() => fixture.close());

      test('signed-in single field change enqueues one field-masked mutation',
          () async {
        await fixture.apply(
          bookmarked: const FieldUpdate.set(true),
          accountId: 'account-a',
        );

        final rows =
            await fixture.database.select(fixture.database.syncOutbox).get();
        expect(rows, hasLength(1));
        final row = rows.single;
        expect(row.accountId, 'account-a');
        expect(row.dataset, fixture.dataset.stableId);
        expect(row.entityId, '1');
        expect(jsonDecode(row.fieldMask), ['isBookmarked']);
        expect(jsonDecode(row.payload), {'isBookmarked': true});
        expect(row.localRevision, 1);
      });

      test('guest write does not enqueue an outbox mutation', () async {
        await fixture.apply(
          bookmarked: const FieldUpdate.set(true),
          accountId: null,
        );

        expect(
            await fixture.database.select(fixture.database.syncOutbox).get(),
            isEmpty);
      });

      test('sequential signed-in edits coalesce and advance local_revision',
          () async {
        await fixture.apply(
          learned: const FieldUpdate.set(true),
          accountId: 'account-a',
        );
        await fixture.apply(
          bookmarked: const FieldUpdate.set(true),
          accountId: 'account-a',
        );

        final rows =
            await fixture.database.select(fixture.database.syncOutbox).get();
        expect(rows, hasLength(1));
        final row = rows.single;
        expect(jsonDecode(row.fieldMask),
            containsAll(['isLearned', 'isBookmarked']));
        expect(jsonDecode(row.payload),
            {'isLearned': true, 'isBookmarked': true});
        expect(row.localRevision, 2);
      });

      test('an unchanged command enqueues nothing even when signed in',
          () async {
        await fixture.apply(accountId: 'account-a');

        expect(
            await fixture.database.select(fixture.database.syncOutbox).get(),
            isEmpty);
      });
    });
  }
}
