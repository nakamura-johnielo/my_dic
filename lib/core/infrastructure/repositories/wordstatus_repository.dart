import 'package:firebase_core/firebase_core.dart';
import 'package:my_dic/core/infrastructure/datasource/word_status/i_local_word_status_data_source.dart';
import 'package:my_dic/core/infrastructure/datasource/word_status/i_remote_word_status_data_source.dart';
import 'package:my_dic/core/shared/errors/infrastructure_errors.dart';
import 'package:my_dic/core/shared/errors/unexpected_error.dart';
import 'package:my_dic/core/shared/utils/result.dart';
import 'package:my_dic/core/domain/entity/word/esp_word_status.dart';
import 'package:my_dic/core/domain/i_repository/i_word_status_repository.dart';
import 'package:my_dic/core/infrastructure/repositories/converters/word_status_converter.dart';
import 'package:my_dic/core/infrastructure/dtos/wordStatusEntity.dart';

class WordStatusRepository implements IWordStatusRepository {
  final IRemoteWordStatusDataSource _remote;
  final ILocalWordStatusDataSource _local;
  WordStatusRepository(this._remote, this._local);

  @override
  Future<Result<void>> updateWordStatus(
    WordStatus wordStatus,
    DateTime now,
    String userId,
  ) async {
    // Update local first
    final localResult = await updateLocalWordStatus(wordStatus, now, userId);
    if (localResult.isFailure) {
      return localResult;
    }

    // Then update remote if user is logged in
    if (userId != "logout" && userId != "anonymous" && userId.isNotEmpty) {
      final remoteResult = await updateRemoteWordStatus(wordStatus, userId, now);
      // Log but don't fail if remote fails (local is already updated)
      if (remoteResult.isFailure) {
        print('Remote update failed: ${remoteResult.errorOrNull?.message}');
      }
    }

    return const Result.success(null);
  }
  
  @override
  Future<Result<void>> updateLocalWordStatus(
    WordStatus wordStatus,
    DateTime now,
    String userId,
  ) async {
    try {
      final input = wordStatus.copyWith(editAt: now);
      final tableData = WordStatusConverter.toTableData(input);

      await _local.updateWordStatus(tableData);

      return const Result.success(null);
    } catch (e, s) {
      return Result.failure(DatabaseError(
        message: 'ローカルの単語ステータス更新に失敗しました',
        originalError: e,
        stackTrace: s,
      ));
    }
  }

  @override
  Future<Result<void>> updateRemoteWordStatus(
    WordStatus wordStatus,
    String userId,
    DateTime? now,
  ) async {
    try {
      final remoteInput = wordStatus.copyWith(editAt: now);
      final dto = WordStatusDTO.fromAppEntity(remoteInput);
      await _remote.updateWordStatus(userId, dto);
      return const Result.success(null);
    } on FirebaseException catch (e, s) {
      return Result.failure(FirebaseError(
        message: 'リモートの単語ステータス更新に失敗しました: ${e.message}',
        code: e.code,
        originalError: e,
        stackTrace: s,
      ));
    } catch (e, s) {
      return Result.failure(UnexpectedError(
        message: 'リモートの単語ステータス更新中に予期しないエラーが発生しました',
        originalError: e,
        stackTrace: s,
      ));
    }
  }

  @override
  Future<Result<void>> deleteWordStatus(WordStatus wordStatus) async {
    // TODO: Implement when needed
    return const Result.success(null);
  }

  @override
  Future<Result<WordStatus?>> getWordStatusById(int id) async {
    try {
      final res = await _local.getWordStatusById(id);
      if (res != null) {
        return Result.success(WordStatusConverter.toEntity(res, id));
      }
      return Result.success(null);
    } catch (e, s) {
      return Result.failure(DatabaseError(
        message: '単語ステータスの取得に失敗しました',
        originalError: e,
        stackTrace: s,
      ));
    }
  }

  @override
  Stream<WordStatus> watchWordStatusById(int id) {
    return _local.watchWordStatusById(id).map((data) {
      if (data == null) throw Exception('Word status not found for id: $id');
      return WordStatusConverter.toEntity(data, id);
    });
  }
  
  @override
  Future<Result<List<WordStatus>>> getLocalWordStatusAfter(
    DateTime datetime,
  ) async {
    try {
      final dataList = await _local.getWordStatusAfter(datetime);
      final entities = WordStatusConverter.toEntityList(dataList);
      return Result.success(entities);
    } catch (e, s) {
      return Result.failure(DatabaseError(
        message: 'ローカルの単語ステータス一覧取得に失敗しました',
        originalError: e,
        stackTrace: s,
      ));
    }
  }
  
  @override
  Future<Result<WordStatus?>> getLocalWordStatusById(int id) async {
    try {
      final data = await _local.getWordStatusById(id);
      if (data == null) {
        return Result.success(null);
      }
      return Result.success(WordStatusConverter.toEntity(data, id));
    } catch (e, s) {
      return Result.failure(DatabaseError(
        message: 'ローカルの単語ステータス取得に失敗しました',
        originalError: e,
        stackTrace: s,
      ));
    }
  }
  
  @override
  Future<Result<List<WordStatus>>> getRemoteWordStatusAfter(
    String userId,
    DateTime datetime,
  ) async {
    try {
      final dtoList = await _remote.getWordStatusAfter(userId, datetime);
      final entities = dtoList.map((dto) => dto.toEntity()).toList();
      return Result.success(entities);
    } on FirebaseException catch (e, s) {
      return Result.failure(FirebaseError(
        message: 'リモートの単語ステータス一覧取得に失敗しました: ${e.message}',
        code: e.code,
        originalError: e,
        stackTrace: s,
      ));
    } catch (e, s) {
      return Result.failure(UnexpectedError(
        message: 'リモートの単語ステータス一覧取得中に予期しないエラーが発生しました',
        originalError: e,
        stackTrace: s,
      ));
    }
  }
  
  @override
  Future<Result<WordStatus?>> getRemoteWordStatusById(
    String userId,
    int id,
  ) async {
    try {
      final dto = await _remote.getWordStatusById(userId, id);
      if (dto == null) {
        return Result.success(null);
      }
      return Result.success(dto.toEntity());
    } on FirebaseException catch (e, s) {
      return Result.failure(FirebaseError(
        message: 'リモートの単語ステータス取得に失敗しました: ${e.message}',
        code: e.code,
        originalError: e,
        stackTrace: s,
      ));
    } catch (e, s) {
      return Result.failure(UnexpectedError(
        message: 'リモートの単語ステータス取得中に予期しないエラーが発生しました',
        originalError: e,
        stackTrace: s,
      ));
    }
  }
  
  @override
  Future<Result<void>> updateBatchRemoteWordStatus(
    List<WordStatus> wordStatusList,
    String userId,
    DateTime? now,
  ) async {
    try {
      final dtoList = wordStatusList.map((w) {
        final updated = now != null ? w.copyWith(editAt: now) : w;
        return WordStatusDTO.fromAppEntity(updated);
      }).toList();

      await _remote.updateWordStatusBatch(userId, dtoList);
      return const Result.success(null);
    } on FirebaseException catch (e, s) {
      return Result.failure(FirebaseError(
        message: 'リモートの単語ステータス一括更新に失敗しました: ${e.message}',
        code: e.code,
        originalError: e,
        stackTrace: s,
      ));
    } catch (e, s) {
      return Result.failure(UnexpectedError(
        message: 'リモートの単語ステータス一括更新中に予期しないエラーが発生しました',
        originalError: e,
        stackTrace: s,
      ));
    }
  }
  
  @override
  Stream<List<int>> watchLocalChangedIds(DateTime datetime) {
    return _local.watchChangedIds(datetime);
  }
  
  @override
  Stream<List<int>> watchRemoteChangedIds(String userId) {
    return _remote.watchChangedIds(userId);
  }
  
}
