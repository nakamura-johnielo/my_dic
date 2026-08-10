import 'dart:convert';

import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:my_dic/core/infrastructure/database/drift/database_provider.dart';
import 'package:my_dic/features/my_word/internal/infrastructure/data/data_source/local/drift_my_word_dao.dart';
import 'package:my_dic/features/my_word/internal/infrastructure/data/data_source/local/my_word_drift_data_source.dart';
import 'package:my_dic/features/my_word/internal/infrastructure/data/repository_impl/my_word_repository.dart';
import 'package:my_dic/features/my_word/internal/domain/model/my_word/register_my_word_repository_input_data.dart';
import 'package:my_dic/features/my_word/internal/domain/model/my_word/delete_my_word_repository_input_data.dart';
import 'package:my_dic/features/my_word/internal/domain/model/my_word/update_my_word_repository_input_data.dart';
import 'package:my_dic/features/sync/infrastructure/persistence/drift/drift_outbox_writer.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late DatabaseProvider database;
  late MyWordRepository repository;

  setUp(() {
    database = DatabaseProvider.forTesting(NativeDatabase.memory());
    final local = MyWordDriftDataSource(MyWordDao(database));
    final writer = DriftOutboxWriter(database, clock: () => DateTime.utc(2026));
    repository = MyWordRepository(local, writer);
  });

  tearDown(() => database.close());

  group('MyWord outbox enqueue on local write', () {
    test('signed-in register enqueues one upsert mutation', () async {
      final result = await repository.registerWord(
        RegisterMyWordRepositoryInputData(
            'hola', 'greeting', DateTime.utc(2026, 8, 5), 'account-a'),
      );
      expect(result.isSuccess, isTrue);
      final wordId = result.dataOrNull!;

      final rows = await database.select(database.syncOutbox).get();
      expect(rows, hasLength(1));
      final row = rows.single;
      expect(row.accountId, 'account-a');
      expect(row.dataset, 'my_words');
      expect(row.entityId, wordId);
      expect(row.operation, 'upsert');
      expect(jsonDecode(row.fieldMask), containsAll(['word', 'contents']));
      expect(jsonDecode(row.payload), {'word': 'hola', 'contents': 'greeting'});
      expect(row.localRevision, 1);
    });

    test('guest register does not enqueue an outbox mutation', () async {
      final result = await repository.registerWord(
        RegisterMyWordRepositoryInputData(
            'hola', 'greeting', DateTime.utc(2026, 8, 5), null),
      );
      expect(result.isSuccess, isTrue);
      expect(await database.select(database.syncOutbox).get(), isEmpty);
    });

    test('signed-in update enqueues a patch mutation and advances revision',
        () async {
      final registerResult = await repository.registerWord(
        RegisterMyWordRepositoryInputData(
            'hola', 'greeting', DateTime.utc(2026, 8, 5), 'account-a'),
      );
      final wordId = registerResult.dataOrNull!;

      final updateResult = await repository.updateWord(
        UpdateMyWordRepositoryInputData(wordId, 'hola!', 'greeting (updated)',
            DateTime.utc(2026, 8, 6), 'account-a'),
      );
      expect(updateResult.isSuccess, isTrue);

      final rows = await database.select(database.syncOutbox).get();
      expect(rows, hasLength(1));
      final row = rows.single;
      expect(row.operation, 'patch');
      expect(jsonDecode(row.payload),
          {'word': 'hola!', 'contents': 'greeting (updated)'});
      expect(row.localRevision, 2);
    });

    test('guest update does not enqueue an outbox mutation', () async {
      final registerResult = await repository.registerWord(
        RegisterMyWordRepositoryInputData(
            'hola', 'greeting', DateTime.utc(2026, 8, 5), null),
      );
      final wordId = registerResult.dataOrNull!;

      final updateResult = await repository.updateWord(
        UpdateMyWordRepositoryInputData(wordId, 'hola!', 'greeting (updated)',
            DateTime.utc(2026, 8, 6), null),
      );
      expect(updateResult.isSuccess, isTrue);
      expect(await database.select(database.syncOutbox).get(), isEmpty);
    });
  });

  group('MyWord tombstone delete', () {
    test('signed-in delete enqueues a delete mutation and hides the word',
        () async {
      final registerResult = await repository.registerWord(
        RegisterMyWordRepositoryInputData(
            'hola', 'greeting', DateTime.utc(2026, 8, 5), 'account-a'),
      );
      final wordId = registerResult.dataOrNull!;

      final deleteResult = await repository.deleteWord(
        DeleteMyWordRepositoryInputData(
            wordId, DateTime.utc(2026, 8, 6).toIso8601String(), 'account-a'),
      );
      expect(deleteResult.isSuccess, isTrue);

      final rows = await database.select(database.syncOutbox).get();
      expect(rows, hasLength(1));
      final row = rows.single;
      expect(row.operation, 'delete');
      expect(row.entityId, wordId);
      expect(row.localRevision, 2);

      final getResult =
          await repository.getById(wordId, accountId: 'account-a');
      expect(getResult.isFailure, isTrue);
    });

    test('guest delete does not enqueue an outbox mutation', () async {
      final registerResult = await repository.registerWord(
        RegisterMyWordRepositoryInputData(
            'hola', 'greeting', DateTime.utc(2026, 8, 5), null),
      );
      final wordId = registerResult.dataOrNull!;

      final deleteResult = await repository.deleteWord(
        DeleteMyWordRepositoryInputData(
            wordId, DateTime.utc(2026, 8, 6).toIso8601String(), null),
      );
      expect(deleteResult.isSuccess, isTrue);
      expect(await database.select(database.syncOutbox).get(), isEmpty);
    });

    test('deleting an already-deleted word returns NotFound', () async {
      final registerResult = await repository.registerWord(
        RegisterMyWordRepositoryInputData(
            'hola', 'greeting', DateTime.utc(2026, 8, 5), 'account-a'),
      );
      final wordId = registerResult.dataOrNull!;
      await repository.deleteWord(
        DeleteMyWordRepositoryInputData(
            wordId, DateTime.utc(2026, 8, 6).toIso8601String(), 'account-a'),
      );

      final secondDelete = await repository.deleteWord(
        DeleteMyWordRepositoryInputData(
            wordId, DateTime.utc(2026, 8, 7).toIso8601String(), 'account-a'),
      );
      expect(secondDelete.isFailure, isTrue);
    });
  });
}
