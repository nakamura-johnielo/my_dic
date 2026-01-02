import 'package:firebase_core/firebase_core.dart';
import 'package:my_dic/core/infrastructure/datasource/word_status/i_local_word_status_data_source.dart';
import 'package:my_dic/core/infrastructure/datasource/word_status/i_remote_word_status_data_source.dart';
import 'package:my_dic/core/shared/errors/infrastructure_errors.dart';
import 'package:my_dic/core/shared/errors/unexpected_error.dart';
import 'package:my_dic/core/shared/utils/result.dart';
import 'package:my_dic/core/domain/entity/word/esp_word_status.dart';
import 'package:my_dic/core/domain/i_repository/i_word_status_repository.dart';
import 'package:my_dic/core/infrastructure/repositories/converters/word_status_converter.dart';

class WordStatusRepository implements IWordStatusRepository {
  final IRemoteWordStatusDataSource _remote;
  final ILocalWordStatusDataSource _local;
  WordStatusRepository(this._remote, this._local);

  @override
  Future<Result<void>> updateWordStatus(WordStatus wordStatus, DateTime now, String userId) {
    // TODO: implement updateWordStatus
    throw UnimplementedError();
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
    DateTime now,
    String userId,
  ) async {
    try {
      final remoteInput = wordStatus.copyWith(editAt: now);
      await _remote.updateWordStatus( userId,remoteInput);
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
  
}
