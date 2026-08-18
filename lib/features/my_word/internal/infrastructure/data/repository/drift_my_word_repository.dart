import 'package:my_dic/core/shared/consts/account_scope.dart';
import 'package:my_dic/core/infrastructure/database/drift/database_provider.dart';
import 'package:my_dic/features/sync/port/dataset_contract.dart';
import 'package:my_dic/core/shared/errors/domain_errors.dart';
import 'package:my_dic/core/shared/utils/result.dart';
import 'package:my_dic/core/shared/utils/uuid.dart';
import 'package:my_dic/features/my_word/internal/infrastructure/data/dataSource/my_word_local_store.dart';
import 'package:my_dic/features/my_word/internal/infrastructure/mapper/my_word_infrastructure_error_mapper.dart';
import 'package:my_dic/features/my_word/internal/domain/entity/my_word.dart';
import 'package:my_dic/features/my_word/internal/domain/repository/my_word_repository.dart';
import 'package:my_dic/features/my_word/internal/domain/repository/delete_my_word_record.dart';
import 'package:my_dic/features/my_word/internal/domain/repository/my_word_page_query.dart';
import 'package:my_dic/features/my_word/internal/domain/repository/register_my_word_record.dart';
import 'package:my_dic/features/my_word/internal/domain/repository/update_my_word_record.dart';
import 'package:uuid/uuid.dart';

final class DriftMyWordRepository implements IMyWordRepository {
  final MyWordLocalDataSource _localStore;
  final OutboxWriter _outboxWriter;
  final Uuid _uuid;

  DriftMyWordRepository(
    this._localStore,
    this._outboxWriter, {
    Uuid? uuid,
  }) : _uuid = uuid ?? const Uuid();

  @override
  Future<Result<MyWord>> getById(String id, {required String accountId}) async {
    try {
      final data = await _localStore.getMyWordById(id, accountId);
      if (data == null) {
        return Result.failure(NotFoundError(message: 'My word was not found.'));
      }
      return Result.success(_toEntity(data));
    } catch (e, s) {
      return Result.failure(MyWordInfrastructureErrorMapper.database(
        e,
        s,
        message: 'Failed to load my word.',
      ));
    }
  }

  @override
  Future<Result<List<MyWord>>> getFilteredByPage(
    MyWordPageQuery input, {
    required String accountId,
  }) async {
    try {
      final data = await _localStore.getFilteredMyWordByPage(
        input.size,
        input.offset,
        accountId,
      );
      return Result.success((data ?? []).map(_toEntity).toList());
    } catch (e, s) {
      return Result.failure(MyWordInfrastructureErrorMapper.database(
        e,
        s,
        message: 'Failed to load my words.',
      ));
    }
  }

  @override
  Future<Result<List<String>>> getIdsFilteredByPage(
    MyWordPageQuery input, {
    required String accountId,
  }) async {
    try {
      final data = await _localStore.getIdsFilteredMyWordByPage(
        input.size,
        input.offset,
        accountId,
      );
      return Result.success(data ?? []);
    } catch (e, s) {
      return Result.failure(MyWordInfrastructureErrorMapper.database(
        e,
        s,
        message: 'Failed to load my word IDs.',
      ));
    }
  }

  @override
  Future<Result<String>> registerWord(
    RegisterMyWordInputData input,
  ) async {
    try {
      final wordId = MyUUID.generate();
      final scope = input.userId ?? guestAccountScope;
      await _localStore.runInTransaction(() async {
        final row = await _localStore.insertMyWordWithRevision(
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
      return Result.failure(MyWordInfrastructureErrorMapper.database(
        e,
        s,
        message: 'Failed to register my word.',
      ));
    }
  }

  @override
  Future<Result<void>> updateWord(UpdateMyWordInputData input) async {
    try {
      final scope = input.userId ?? guestAccountScope;
      final updated = await _localStore.runInTransaction(() async {
        final row = await _localStore.updateMyWordWithRevision(
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
      return Result.failure(MyWordInfrastructureErrorMapper.database(
        e,
        s,
        message: 'Failed to update my word.',
      ));
    }
  }

  @override
  Future<Result<void>> deleteWord(DeleteMyWordInputData input) async {
    try {
      final scope = input.userId ?? guestAccountScope;
      final tombstoned = await _localStore.runInTransaction(() async {
        final row = await _localStore.tombstoneMyWord(
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
      return Result.failure(MyWordInfrastructureErrorMapper.database(
        e,
        s,
        message: 'Failed to delete my word.',
      ));
    }
  }

  @override
  Stream<MyWord> watchMyWord(String id, {required String accountId}) {
    return _localStore.streamMyWordById(id, accountId).map((data) {
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
