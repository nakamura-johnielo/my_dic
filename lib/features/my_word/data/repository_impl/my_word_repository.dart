import 'package:firebase_core/firebase_core.dart';
import 'package:uuid/uuid.dart';
import 'package:my_dic/core/shared/consts/account_scope.dart';
import 'package:my_dic/core/shared/enums/sync_dataset.dart';
import 'package:my_dic/core/shared/errors/domain_errors.dart';
import 'package:my_dic/core/shared/errors/infrastructure_errors.dart';
import 'package:my_dic/core/shared/errors/unexpected_error.dart';
import 'package:my_dic/core/shared/utils/result.dart';
import 'package:my_dic/core/shared/utils/uuid.dart';
import 'package:my_dic/features/my_word/domain/usecase/my_word/create/register_my_word/register_my_word_repository_input_data.dart';
import 'package:my_dic/features/my_word/domain/usecase/my_word/delete/delete_my_word/delete_my_word_repository_input_data.dart';
import 'package:my_dic/features/my_word/domain/usecase/my_word/update/update_my_word/update_my_word_repository_input_data.dart';
import 'package:my_dic/features/my_word/domain/entity/my_word.dart';
import 'package:my_dic/features/my_word/domain/i_repository/i_my_word_repository.dart';
import 'package:my_dic/features/my_word/domain/usecase/my_word/load_my_word/load_my_word_repository_input_data.dart';
import 'package:my_dic/features/my_word/data/data_source/local/i_my_word_local_data_source.dart';
import 'package:my_dic/features/my_word/data/data_source/remote/myword/i_my_word_remote_data_source.dart';
import 'package:my_dic/features/my_word/data/data_source/remote/myword/firebase_my_word_dto.dart';
import 'package:my_dic/features/sync/application/model/sync_mutation.dart';
import 'package:my_dic/features/sync/application/port/outbox_writer.dart';

class MyWordRepository implements IMyWordRepository {
  final IMyWordLocalDataSource _localDataSource;
  final IMyWordRemoteDataSource _remoteDataSource;
  final OutboxWriter _outboxWriter;
  final Uuid _uuid;

  MyWordRepository(
    this._localDataSource,
    this._remoteDataSource,
    this._outboxWriter, {
    Uuid? uuid,
  }) : _uuid = uuid ?? const Uuid();

  @override
  Future<Result<MyWord>> getById(String id, {required String accountId}) async {
    try {
      final data = await _localDataSource.getMyWordById(id, accountId);
      if (data == null) {
        return Result.failure(NotFoundError(
          message: '指定された単語が見つかりません',
        ));
      }
      final entity = MyWord(
        wordId: data.myWordId,
        word: data.word,
        contents: data.contents ?? '',
        isLearned: false,
        isBookmarked: false,
        editAt: DateTime.parse(data.editAt).toUtc(),
      );
      return Result.success(entity);
    } catch (e, s) {
      return Result.failure(DatabaseError(
        message: '単語の取得に失敗しました',
        originalError: e,
        stackTrace: s,
      ));
    }
  }

  @override
  Future<Result<List<MyWord>>> getFilteredByPage(
      LoadMyWordRepositoryInputData input,
      {required String accountId}) async {
    try {
      final dataList = await _localDataSource.getFilteredMyWordByPage(
          input.size, input.offset, accountId);
      if (dataList == null) {
        return const Result.success([]);
      }
      final entities = dataList
          .map((data) => MyWord(
                wordId: data.myWordId,
                word: data.word,
                contents: data.contents ?? '',
                isLearned: false,
                isBookmarked: false,
                editAt: DateTime.parse(data.editAt).toUtc(),
              ))
          .toList();
      return Result.success(entities);
    } catch (e, s) {
      return Result.failure(DatabaseError(
        message: '単語リストの取得に失敗しました',
        originalError: e,
        stackTrace: s,
      ));
    }
  }

  @override
  Future<Result<List<String>>> getIdsFilteredByPage(
      LoadMyWordRepositoryInputData input,
      {required String accountId}) async {
    try {
      final dataList = await _localDataSource.getIdsFilteredMyWordByPage(
          input.size, input.offset, accountId);
      if (dataList == null) {
        return const Result.success([]);
      }

      return Result.success(dataList);
    } catch (e, s) {
      return Result.failure(DatabaseError(
        message: '単語リストの取得に失敗しました',
        originalError: e,
        stackTrace: s,
      ));
    }
  }

  @override
  Future<Result<String>> registerWord(
      RegisterMyWordRepositoryInputData input) async {
    try {
      // Check for duplicate words
      // Note: This would require a DAO method to check existence
      // For now, we'll handle the database constraint error

      final wordId = MyUUID.generate();
      final editAt = input.dateTime.toIso8601String();
      final scope = input.userId ?? guestAccountScope;
      await _localDataSource.runInTransaction(() async {
        final row = await _localDataSource.insertMyWordWithRevision(
          id: wordId,
          word: input.headword,
          contents: input.description,
          editAt: editAt,
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
        return row;
      });

      return Result.success(wordId);
    } catch (e, s) {
      // Check if it's a unique constraint violation
      if (e.toString().contains('UNIQUE constraint failed') ||
          e.toString().contains('duplicate')) {
        return Result.failure(BusinessRuleError(
          message: 'この単語は既に登録されています',
          originalError: e,
          stackTrace: s,
        ));
      }
      return Result.failure(DatabaseError(
        message: '単語の登録に失敗しました',
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
            input.id, input.dateTime, scope);
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
        return Result.failure(NotFoundError(
          message: '削除する単語が見つかりません',
        ));
      }
      return const Result.success(null);
    } catch (e, s) {
      return Result.failure(DatabaseError(
        message: '単語の削除に失敗しました',
        originalError: e,
        stackTrace: s,
      ));
    }
  }

  @override
  Future<Result<void>> updateWord(UpdateMyWordRepositoryInputData input) async {
    try {
      final editAt = input.editAt.toIso8601String();
      final scope = input.userId ?? guestAccountScope;
      final updated = await _localDataSource.runInTransaction(() async {
        final row = await _localDataSource.updateMyWordWithRevision(
          id: input.myWordId,
          word: input.headword,
          contents: input.description,
          editAt: editAt,
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
        return Result.failure(NotFoundError(
          message: '更新する単語が見つかりません',
        ));
      }
      return const Result.success(null);
    } catch (e, s) {
      return Result.failure(DatabaseError(
        message: '単語の更新に失敗しました',
        originalError: e,
        stackTrace: s,
      ));
    }
  }

  // ============================================================================
  // Remote Methods
  // ============================================================================

  @override
  Future<Result<List<MyWord>>> getRemoteMyWordsAfter(
      String userId, DateTime datetime) async {
    try {
      final dtoList = await _remoteDataSource.getMyWordsAfter(userId, datetime);
      final entities = dtoList.map((dto) => dto.toEntity()).toList();
      return Result.success(entities);
    } on FirebaseException catch (e, s) {
      return Result.failure(FirebaseError(
        message: 'リモートの単語取得に失敗しました: ${e.message}',
        code: e.code,
        originalError: e,
        stackTrace: s,
      ));
    } catch (e, s) {
      return Result.failure(UnexpectedError(
        message: 'リモートの単語取得中に予期しないエラーが発生しました',
        originalError: e,
        stackTrace: s,
      ));
    }
  }

  @override
  Future<Result<MyWord?>> getRemoteMyWordById(
      String userId, String myWordId) async {
    try {
      final dto = await _remoteDataSource.getMyWordById(userId, myWordId);
      return Result.success(dto?.toEntity());
    } on FirebaseException catch (e, s) {
      return Result.failure(FirebaseError(
        message: 'リモートの単語取得に失敗しました: ${e.message}',
        code: e.code,
        originalError: e,
        stackTrace: s,
      ));
    } catch (e, s) {
      return Result.failure(UnexpectedError(
        message: 'リモートの単語取得中に予期しないエラーが発生しました',
        originalError: e,
        stackTrace: s,
      ));
    }
  }

  @override
  Future<Result<void>> updateRemoteMyWord(
      String userId, MyWord myWord, DateTime? now) async {
    try {
      final updatedMyWord =
          myWord.copyWith(editAt: now ?? DateTime.now().toUtc());
      final dto = MyWordDTO.fromAppEntity(updatedMyWord);
      await _remoteDataSource.updateMyWord(userId, dto);
      return const Result.success(null);
    } on FirebaseException catch (e, s) {
      return Result.failure(FirebaseError(
        message: 'リモートの単語更新に失敗しました: ${e.message}',
        code: e.code,
        originalError: e,
        stackTrace: s,
      ));
    } catch (e, s) {
      return Result.failure(UnexpectedError(
        message: 'リモートの単語更新中に予期しないエラーが発生しました',
        originalError: e,
        stackTrace: s,
      ));
    }
  }

  @override
  Future<Result<void>> updateBatchRemoteMyWords(
      String userId, List<MyWord> myWordList) async {
    try {
      final dtoList =
          myWordList.map((word) => MyWordDTO.fromAppEntity(word)).toList();
      await _remoteDataSource.updateMyWordBatch(userId, dtoList);
      return const Result.success(null);
    } on FirebaseException catch (e, s) {
      return Result.failure(FirebaseError(
        message: 'リモートの単語一括更新に失敗しました: ${e.message}',
        code: e.code,
        originalError: e,
        stackTrace: s,
      ));
    } catch (e, s) {
      return Result.failure(UnexpectedError(
        message: 'リモートの単語一括更新中に予期しないエラーが発生しました',
        originalError: e,
        stackTrace: s,
      ));
    }
  }

  @override
  Future<Result<void>> deleteRemoteMyWord(
      String userId, String myWordId) async {
    try {
      await _remoteDataSource.deleteMyWord(userId, myWordId);
      return const Result.success(null);
    } on FirebaseException catch (e, s) {
      return Result.failure(FirebaseError(
        message: 'リモートの単語削除に失敗しました: ${e.message}',
        code: e.code,
        originalError: e,
        stackTrace: s,
      ));
    } catch (e, s) {
      return Result.failure(UnexpectedError(
        message: 'リモートの単語削除中に予期しないエラーが発生しました',
        originalError: e,
        stackTrace: s,
      ));
    }
  }

  // ============================================================================
  // Local Methods for Sync
  // ============================================================================

  @override
  Future<Result<List<MyWord>>> getLocalMyWordsAfter(DateTime datetime) async {
    try {
      final rows = await _localDataSource
          .getMyWordsAfter(datetime.toUtc().toIso8601String());
      final entities = rows
          .map(
            (r) => MyWord(
              wordId: r.myWordId,
              word: r.word,
              contents: r.contents ?? '',
              editAt: DateTime.parse(r.editAt).toUtc(),
            ),
          )
          .toList();
      return Result.success(entities);
    } catch (e, s) {
      return Result.failure(DatabaseError(
        message: 'ローカルの単語取得に失敗しました',
        originalError: e,
        stackTrace: s,
      ));
    }
  }

  @override
  Future<Result<MyWord?>> getLocalMyWordById(String myWordId) async {
    // Legacy sync path predates real account scoping; preserves prior
    // behavior by keeping the same fixed scope it always used.
    return await getById(myWordId, accountId: guestAccountScope);
  }

  @override
  Future<Result<void>> updateLocalMyWord(MyWord myWord, DateTime now) async {
    try {
      // Need to add updateMyWordFromData method to data source
      // For now, use existing updateMyWord
      final affectedRows = await _localDataSource.updateMyWord(
        myWord.wordId,
        myWord.word,
        myWord.contents,
        now.toIso8601String(),
      );
      if (affectedRows == 0) {
        return Result.failure(NotFoundError(
          message: '更新する単語が見つかりません',
        ));
      }
      return const Result.success(null);
    } catch (e, s) {
      return Result.failure(DatabaseError(
        message: 'ローカルの単語更新に失敗しました',
        originalError: e,
        stackTrace: s,
      ));
    }
  }

  @override
  Future<Result<void>> createLocalMyWord(MyWord myWord) async {
    try {
      await _localDataSource.insertMyWord(
        myWord.wordId,
        myWord.word,
        myWord.contents,
        myWord.editAt.toIso8601String(),
      );
      return const Result.success(null);
    } catch (e, s) {
      return Result.failure(DatabaseError(
        message: 'ローカルの単語作成に失敗しました',
        originalError: e,
        stackTrace: s,
      ));
    }
  }

  // ============================================================================
  // Watch Streams
  // ============================================================================

  @override
  Stream<List<String>> watchRemoteChangedIds(String userId) {
    return _remoteDataSource.watchChangedIds(userId);
  }

  @override
  Stream<List<String>> watchLocalChangedIds(DateTime datetime) {
    return _localDataSource
        .watchMyWordIdsAfter(datetime.toUtc().toIso8601String());
  }

  @override
  Stream<MyWord> watchMyWord(String id, {required String accountId}) {
    return _localDataSource.streamMyWordById(id, accountId).map((data) {
      if (data == null) {
        throw NotFoundError(message: '指定された単語が見つかりません');
      }
      return MyWord(
          wordId: data.myWordId,
          word: data.word,
          contents: data.contents ?? '',
          isLearned: false,
          isBookmarked: false,
          editAt: DateTime.parse(data.editAt).toUtc());
    });
  }
}
