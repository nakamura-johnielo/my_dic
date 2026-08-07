import 'dart:convert';

import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:my_dic/core/infrastructure/database/drift/database_provider.dart';
import 'package:my_dic/features/my_word/data/data_source/local/drift_my_word_status_dao.dart';
import 'package:my_dic/features/my_word/data/data_source/local/my_word_status_drift_data_source.dart';
import 'package:my_dic/features/my_word/data/repository_impl/my_word_status_repository.dart';
import 'package:my_dic/features/my_word/domain/model/my_word_status/update_my_word_status_repository_input_data.dart';
import 'package:my_dic/features/sync/infrastructure/persistence/drift/drift_outbox_writer.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late DatabaseProvider database;
  late MyWordStatusRepository repository;

  setUp(() {
    database = DatabaseProvider.forTesting(NativeDatabase.memory());
    final local = MyWordStatusDriftDataSource(MyWordStatusDao(database));
    final writer = DriftOutboxWriter(database, clock: () => DateTime.utc(2026));
    repository = MyWordStatusRepository(local, writer);
  });

  tearDown(() => database.close());

  test('signed-in single field change enqueues one field-masked mutation',
      () async {
    final result = await repository.updateStatus(
      UpdateMyWordStatusRepositoryInputData(
          'word-1', null, 1, null, DateTime.utc(2026, 8, 5), 'account-a'),
    );
    expect(result.isSuccess, isTrue);

    final rows = await database.select(database.syncOutbox).get();
    expect(rows, hasLength(1));
    final row = rows.single;
    expect(row.accountId, 'account-a');
    expect(row.dataset, 'my_word_status');
    expect(row.entityId, 'word-1');
    expect(jsonDecode(row.fieldMask), ['isBookmarked']);
    expect(jsonDecode(row.payload), {'isBookmarked': true});
    expect(row.localRevision, 1);
  });

  test('guest write does not enqueue an outbox mutation', () async {
    final result = await repository.updateStatus(
      UpdateMyWordStatusRepositoryInputData(
          'word-1', null, 1, null, DateTime.utc(2026, 8, 5), null),
    );
    expect(result.isSuccess, isTrue);
    expect(await database.select(database.syncOutbox).get(), isEmpty);
  });

  test('sequential signed-in edits coalesce and advance local_revision',
      () async {
    await repository.updateStatus(
      UpdateMyWordStatusRepositoryInputData(
          'word-1', 1, null, null, DateTime.utc(2026, 8, 5), 'account-a'),
    );
    await repository.updateStatus(
      UpdateMyWordStatusRepositoryInputData(
          'word-1', null, 1, null, DateTime.utc(2026, 8, 6), 'account-a'),
    );

    final rows = await database.select(database.syncOutbox).get();
    expect(rows, hasLength(1));
    final row = rows.single;
    expect(
        jsonDecode(row.fieldMask), containsAll(['isLearned', 'isBookmarked']));
    expect(row.localRevision, 2);
  });

  test('an unchanged command enqueues nothing even when signed in', () async {
    final result = await repository.updateStatus(
      UpdateMyWordStatusRepositoryInputData(
          'word-1', null, null, null, DateTime.utc(2026, 8, 5), 'account-a'),
    );
    expect(result.isSuccess, isTrue);
    expect(await database.select(database.syncOutbox).get(), isEmpty);
  });
}
