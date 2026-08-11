import 'package:my_dic/core/shared/consts/account_scope.dart';
import 'package:my_dic/core/infrastructure/database/drift/database_provider.dart';
import 'package:my_dic/features/sync/port/sync_dataset.dart';
import 'package:my_dic/core/shared/errors/domain_errors.dart';
import 'package:my_dic/core/shared/errors/infrastructure_errors.dart';
import 'package:my_dic/core/shared/utils/result.dart';
import 'package:my_dic/core/shared/utils/uuid.dart';
import 'package:my_dic/features/my_word/internal/infrastructure/data/data_source/local/i_my_word_local_data_source.dart';
import 'package:my_dic/features/my_word/internal/domain/entity/my_word.dart';
import 'package:my_dic/features/my_word/internal/domain/i_repository/i_my_word_repository.dart';
import 'package:my_dic/features/my_word/internal/domain/inputData/my_word/delete_my_word_repository_input_data.dart';
import 'package:my_dic/features/my_word/internal/domain/inputData/my_word/load_my_word_repository_input_data.dart';
import 'package:my_dic/features/my_word/internal/domain/inputData/my_word/register_my_word_repository_input_data.dart';
import 'package:my_dic/features/my_word/internal/domain/inputData/my_word/update_my_word_repository_input_data.dart';
import 'package:my_dic/features/sync/port/model/sync_mutation.dart';
import 'package:my_dic/features/sync/port/outbox_writer.dart';
import 'package:uuid/uuid.dart';

class MyWordRepository implements IMyWordRepository {
  final IMyWordLocalDataSource _localDataSource;
  final OutboxWriter _outboxWriter;
  final Uuid _uuid;

  MyWordRepository(
    this._localDataSource,
    this._outboxWriter, {
    Uuid? uuid,
  }) : _uuid = uuid ?? const Uuid();

  @override
  Future<Result<MyWord>> getById(String id, {required String accountId}) async {
    try {
      final data = await _localDataSource.getMyWordById(id, accountId);
      if (data == null) {
        return Result.failure(NotFoundError(message: 'My word was not found.'));
      }
      return Result.success(_toEntity(data));
    } catch (e, s) {
      return Result.failure(DatabaseError(
        message: 'Failed to load my word.',
        originalError: e,
        stackTrace: s,
      ));
    }
  }

  @override
  Future<Result<List<MyWord>>> getFilteredByPage(
    LoadMyWordRepositoryInputData input, {
    required String accountId,
  }) async {
    try {
      final data = await _localDataSource.getFilteredMyWordByPage(
        input.size,
        input.offset,
        accountId,
      );
      return Result.success((data ?? []).map(_toEntity).toList());
    } catch (e, s) {
      return Result.failure(DatabaseError(
        message: 'Failed to load my words.',
        originalError: e,
        stackTrace: s,
      ));
    }
  }

  @override
  Future<Result<List<String>>> getIdsFilteredByPage(
    LoadMyWordRepositoryInputData input, {
    required String accountId,
  }) async {
    try {
      final data = await _localDataSource.getIdsFilteredMyWordByPage(
        input.size,
        input.offset,
        accountId,
      );
      return Result.success(data ?? []);
    } catch (e, s) {
      return Result.failure(DatabaseError(
        message: 'Failed to load my word IDs.',
        originalError: e,
        stackTrace: s,
      ));
    }
  }

  @override
  Future<Result<String>> registerWord(
    RegisterMyWordRepositoryInputData input,
  ) async {
    try {
      final wordId = MyUUID.generate();
      final scope = input.userId ?? guestAccountScope;
      await _localDataSource.runInTransaction(() async {
        final row = await _localDataSource.insertMyWordWithRevision(
          id: wordId,
          word: input.headword,
          contents: input.description,
          editAt: input.dateTime.toIso8601String(),
          accountId: scope,
        );
        if (input.userId != null) {
          await _outboxWriter.enqueue(SyncMutation(
            mutationId: _uuid.v4(),
            accountId: input.userId!,
            dataset: SyncDataset.myWords,
            entityId: wordId,
            operation: SyncMutationOperation.upsert,
            payload: {'word': row.word, 'contents': row.contents},
            fieldMask: const ['word', 'contents'],
            localRevision: row.localRevision,
            clientUpdatedAt: input.dateTime.toUtc(),
          ));
        }
      });
      return Result.success(wordId);
    } catch (e, s) {
      if (e.toString().contains('UNIQUE constraint failed') ||
          e.toString().contains('duplicate')) {
        return Result.failure(BusinessRuleError(
          message: 'This word is already registered.',
          originalError: e,
          stackTrace: s,
        ));
      }
      return Result.failure(DatabaseError(
        message: 'Failed to register my word.',
        originalError: e,
        stackTrace: s,
      ));
    }
  }

  @override
  Future<Result<void>> updateWord(UpdateMyWordRepositoryInputData input) async {
    try {
      final scope = input.userId ?? guestAccountScope;
      final updated = await _localDataSource.runInTransaction(() async {
        final row = await _localDataSource.updateMyWordWithRevision(
          id: input.myWordId,
          word: input.headword,
          contents: input.description,
          editAt: input.editAt.toIso8601String(),
          accountId: scope,
        );
        if (row != null && input.userId != null) {
          await _outboxWriter.enqueue(SyncMutation(
            mutationId: _uuid.v4(),
            accountId: input.userId!,
            dataset: SyncDataset.myWords,
            entityId: input.myWordId,
            operation: SyncMutationOperation.patch,
            payload: {'word': row.word, 'contents': row.contents},
            fieldMask: const ['word', 'contents'],
            localRevision: row.localRevision,
            clientUpdatedAt: input.editAt.toUtc(),
          ));
        }
        return row;
      });
      if (updated == null) {
        return Result.failure(NotFoundError(message: 'My word was not found.'));
      }
      return const Result.success(null);
    } catch (e, s) {
      return Result.failure(DatabaseError(
        message: 'Failed to update my word.',
        originalError: e,
        stackTrace: s,
      ));
    }
  }

  @override
  Future<Result<void>> deleteWord(DeleteMyWordRepositoryInputData input) async {
    try {
      final scope = input.userId ?? guestAccountScope;
      final tombstoned = await _localDataSource.runInTransaction(() async {
        final row = await _localDataSource.tombstoneMyWord(
          input.id,
          input.dateTime,
          scope,
        );
        if (row != null && input.userId != null) {
          await _outboxWriter.enqueue(SyncMutation(
            mutationId: _uuid.v4(),
            accountId: input.userId!,
            dataset: SyncDataset.myWords,
            entityId: input.id,
            operation: SyncMutationOperation.delete,
            payload: {'deletedAt': input.dateTime},
            fieldMask: const ['deletedAt'],
            localRevision: row.localRevision,
            clientUpdatedAt: DateTime.parse(input.dateTime).toUtc(),
          ));
        }
        return row;
      });
      if (tombstoned == null) {
        return Result.failure(NotFoundError(message: 'My word was not found.'));
      }
      return const Result.success(null);
    } catch (e, s) {
      return Result.failure(DatabaseError(
        message: 'Failed to delete my word.',
        originalError: e,
        stackTrace: s,
      ));
    }
  }

  @override
  Stream<MyWord> watchMyWord(String id, {required String accountId}) {
    return _localDataSource.streamMyWordById(id, accountId).map((data) {
      if (data == null) {
        throw NotFoundError(message: 'My word was not found.');
      }
      return _toEntity(data);
    });
  }

  MyWord _toEntity(MyWordTableData data) => MyWord(
        wordId: data.myWordId,
        word: data.word,
        contents: data.contents ?? '',
        editAt: DateTime.parse(data.editAt).toUtc(),
      );
}
