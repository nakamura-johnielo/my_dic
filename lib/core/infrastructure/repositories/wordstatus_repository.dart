import 'package:firebase_core/firebase_core.dart';
import 'package:my_dic/core/shared/errors/infrastructure_errors.dart';
import 'package:my_dic/core/shared/errors/unexpected_error.dart';
import 'package:my_dic/core/shared/utils/result.dart';
import 'package:my_dic/core/domain/entity/word/esp_word_status.dart';
import 'package:my_dic/core/domain/i_repository/i_word_status_repository.dart';
import 'package:my_dic/core/infrastructure/database/drift/daos/esp_jpn/esp_jpn_word_status_dao.dart'
    ;
// import 'package:my_dic/_Framework_Driver/local/drift/Entity/word_status.dart'
//     as local;
import 'package:my_dic/core/infrastructure/database/firebase/daos/firebase_word_status_dao.dart'
    ;
import 'package:my_dic/core/infrastructure/database/drift/database_provider.dart';
import 'package:my_dic/core/infrastructure/dtos/wordStatusEntity.dart';

class WordStatusRepository implements IWordStatusRepository {
  final FirebaseWordStatusDao _remote;
  final EspJpnWordStatusDao _local;
  WordStatusRepository(this._remote, this._local);

  @override
  Future<Result<void>> updateLocalWordStatus(
      WordStatus wordStatus, DateTime now, String userId,) async {
    try {
      final nowDateTime = now;
      final localInput = EspJpnWordStatusTableData(
        wordId: wordStatus.wordId,
        isLearned: wordStatus.isLearned ? 1 : 0,
        isBookmarked: wordStatus.isBookmarked ? 1 : 0,
        hasNote: wordStatus.hasNote ? 1 : 0,
        editAt: nowDateTime.toIso8601String(),
      );

      if (await _local.exist(wordStatus.wordId)) {
        await _local.updateStatus(localInput);
      } else {
        await _local.insertStatus(localInput);
      }
      
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
      WordStatus wordStatus, DateTime now, String userId,) async {
    try {
      WordStatusDTO remoteInput = WordStatusDTO.fromAppEntity(wordStatus);
      remoteInput.updatedAt = now;
      await _remote.update(remoteInput, userId);
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
      final res = await _local.getStatusById(id);
      if (res != null) {
        return Result.success(WordStatus(
          wordId: id,
          isBookmarked: res.isBookmarked == 1 ? true : false,
          isLearned: res.isLearned == 1 ? true : false,
          hasNote: res.hasNote == 1 ? true : false,
        ));
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
   return  _local.watchWordStatus(id).map((event) {
      if(event == null){
        return WordStatus(wordId: id);
      }
      return WordStatus(
        wordId: id,
        isBookmarked: event.isBookmarked == 1 ? true : false,
        isLearned: event.isLearned == 1 ? true : false,
        hasNote: event.hasNote == 1 ? true : false,
      );
    });
  }

 }
