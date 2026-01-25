import 'dart:developer';

import 'package:firebase_core/firebase_core.dart';
import 'package:my_dic/core/shared/errors/domain_errors.dart';
import 'package:my_dic/core/shared/errors/infrastructure_errors.dart';
import 'package:my_dic/core/shared/errors/unexpected_error.dart';
import 'package:my_dic/core/shared/utils/result.dart';
import 'package:my_dic/features/my_word/domain/usecase/my_word/create/register_my_word/register_my_word_repository_input_data.dart';
import 'package:my_dic/features/my_word/domain/usecase/my_word/delete/delete_my_word/delete_my_word_repository_input_data.dart';
import 'package:my_dic/features/my_word/domain/usecase/my_word/update/update_my_word/update_my_word_repository_input_data.dart';
import 'package:my_dic/features/my_word/domain/entity/my_word.dart';
import 'package:my_dic/features/my_word/domain/i_repository/i_my_word_repository.dart';
import 'package:my_dic/features/my_word/domain/usecase/my_word/load_my_word/load_my_word_repository_input_data.dart';
import 'package:my_dic/features/my_word/data/data_source/local/i_my_word_local_data_source.dart';
import 'package:my_dic/features/my_word/data/data_source/remote/myword/i_my_word_remote_data_source.dart';
import 'package:my_dic/features/my_word/data/data_source/remote/myword/firebase_my_word_dto.dart';
import 'package:my_dic/core/infrastructure/database/drift/database_provider.dart';

class MyWordRepository implements IMyWordRepository {
  final IMyWordLocalDataSource _localDataSource;
  final IMyWordRemoteDataSource _remoteDataSource;

  MyWordRepository(this._localDataSource, this._remoteDataSource);

  @override
  Future<Result<MyWord>> getById(int id) async {
    try {
      final data = await _localDataSource.getMyWordById(id);
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
      LoadMyWordRepositoryInputData input) async {
    try {
      final dataList = await _localDataSource.getFilteredMyWordByPage(
          input.size, input.offset);
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
  Future<Result<List<int>>> getIdsFilteredByPage(
      LoadMyWordRepositoryInputData input) async {
    try {
      final dataList = await _localDataSource.getIdsFilteredMyWordByPage(
          input.size, input.offset);
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
  Future<Result<int>> registerWord(
      RegisterMyWordRepositoryInputData input) async {
    try {
      // Check for duplicate words
      // Note: This would require a DAO method to check existence
      // For now, we'll handle the database constraint error

      final wordId = await _localDataSource.insertMyWord(
          input.headword, input.description, input.dateTime.toIso8601String());

      final myWord = MyWord(
          wordId: wordId,
          word: input.headword,
          contents: input.description,
          editAt: input.dateTime);

      if (input.userId == null) return Result.success(wordId);
      await _remoteDataSource.updateMyWord(
          input.userId!, MyWordDTO.fromAppEntity(myWord));
      // input.headword, input.description, input.dateTime);
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
      final affectedRows =
          await _localDataSource.deleteMyword(input.id, input.dateTime);
      if (affectedRows == 0) {
        return Result.failure(NotFoundError(
          message: '削除する単語が見つかりません',
        ));
      }
      if (input.userId == null) return const Result.success(null);
      await _remoteDataSource.deleteMyWord(input.userId!, input.id);

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
      final affectedRows = await _localDataSource.updateMyWord(input.myWordId,
          input.headword, input.description, input.editAt.toIso8601String());

      if (affectedRows == 0) {
        return Result.failure(NotFoundError(
          message: '更新する単語が見つかりません',
        ));
      }
      if (input.userId == null) return const Result.success(null);
      final myWord = MyWord(
          wordId: input.myWordId,
          word: input.headword,
          contents: input.description,
          editAt: input.editAt);
      await _remoteDataSource.updateMyWord(
          input.userId!, MyWordDTO.fromAppEntity(myWord));
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
      String userId, int myWordId) async {
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
  Future<Result<void>> deleteRemoteMyWord(String userId, int myWordId) async {
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
  Future<Result<MyWord?>> getLocalMyWordById(int myWordId) async {
    return await getById(myWordId);
  }

  @override
  Future<Result<void>> updateLocalMyWord(MyWord myWord, DateTime now) async {
    try {
      final data = MyWordTableData(
        myWordId: myWord.wordId,
        word: myWord.word,
        contents: myWord.contents,
        editAt: now.toIso8601String(),
      );
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
  Stream<List<int>> watchRemoteChangedIds(String userId) {
    return _remoteDataSource.watchChangedIds(userId);
  }

  @override
  Stream<List<int>> watchLocalChangedIds(DateTime datetime) {
    return _localDataSource
        .watchMyWordIdsAfter(datetime.toUtc().toIso8601String());
  }
  
  @override
  Stream<MyWord> streamMyWord(int id) {
    return _localDataSource.streamMyWordById(id).map((data) {
      if (data == null) {
        throw NotFoundError(message: '指定された単語が見つかりません');
      }
      return MyWord(
        wordId: data.myWordId,
        word: data.word,
        contents: data.contents ?? '',
        isLearned: false,
        isBookmarked: false,
      );
    });
  }
}
