import 'package:firebase_core/firebase_core.dart';
import 'package:my_dic/core/shared/utils/logger.dart';
import 'package:my_dic/core/infrastructure/datasource/jpn_esp_word_status/i_local_jpn_esp_word_status_data_source.dart';
import 'package:my_dic/core/infrastructure/datasource/jpn_esp_word_status/i_remote_jpn_esp_word_status_data_source.dart';
import 'package:my_dic/core/shared/errors/infrastructure_errors.dart';
import 'package:my_dic/core/shared/errors/unexpected_error.dart';
import 'package:my_dic/core/shared/utils/result.dart';
import 'package:my_dic/features/jpn_esp_word_status/domain/jpn_esp_word_status.dart';
import 'package:my_dic/features/jpn_esp_word_status/domain/i_jpn_esp_word_status_repository.dart';
import 'package:my_dic/features/jpn_esp_word_status/domain/usecase/update_jpn_esp_status/update_jpn_esp_status_repository_input_data.dart';
import 'package:my_dic/features/jpn_esp_word_status/data/converter/jpn_esp_word_status_converter.dart';
import 'package:my_dic/features/jpn_esp_word_status/data/jpn_esp_word_status_entity.dart';
import 'package:my_dic/core/shared/value_objects/field_update.dart';

class JpnEspWordStatusRepository implements IJpnEspWordStatusRepository {
  final IRemoteJpnEspWordStatusDataSource _remote;
  final ILocalJpnEspWordStatusDataSource _local;
  JpnEspWordStatusRepository(this._remote, this._local);

  @override
  Future<Result<JpnEspWordStatus>> updateLocalWordStatus(
    UpdateJpnEspStatusRepositoryInputData input,
    DateTime editAt,
  ) async {
    try {
      final updated = await _local.updateWordStatus(
        input.wordId,
        _changedValue(input.isLearned),
        _changedValue(input.isBookmarked),
        _changedValue(input.hasNote),
        editAt.toIso8601String(),
      );

      AppLogger.print("JpnEsp local update success");
      return Result.success(JpnEspWordStatusConverter.toEntity(updated));
    } catch (e, s) {
      AppLogger.print("JpnEsp local update failed: $e");
      return Result.failure(DatabaseError(
        message: 'ローカルのJpnEsp単語ステータス更新に失敗しました',
        originalError: e,
        stackTrace: s,
      ));
    }
  }

  bool? _changedValue(FieldUpdate<bool> update) => switch (update) {
        Unchanged<bool>() => null,
        SetValue<bool>(:final value) => value,
      };

  @override
  Future<Result<void>> updateRemoteWordStatus(
    JpnEspWordStatus wordStatus,
    String userId,
    DateTime? now,
  ) async {
    try {
      final remoteInput = wordStatus.copyWith(editAt: now);
      final dto = JpnEspWordStatusDTO.fromDomain(remoteInput);
      await _remote.updateWordStatus(userId, dto);
      return const Result.success(null);
    } on FirebaseException catch (e, s) {
      return Result.failure(FirebaseError(
        message: 'リモートのJpnEsp単語ステータス更新に失敗しました: ${e.message}',
        code: e.code,
        originalError: e,
        stackTrace: s,
      ));
    } catch (e, s) {
      return Result.failure(UnexpectedError(
        message: 'リモートのJpnEsp単語ステータス更新中に予期しないエラーが発生しました',
        originalError: e,
        stackTrace: s,
      ));
    }
  }

  @override
  Future<Result<void>> deleteWordStatus(JpnEspWordStatus wordStatus) async {
    // TODO: Implement when needed
    return const Result.success(null);
  }

  @override
  Future<Result<JpnEspWordStatus?>> getWordStatusById(int id) async {
    try {
      final res = await _local.getWordStatusById(id);
      if (res != null) {
        return Result.success(JpnEspWordStatusConverter.toEntity(res));
      }
      return Result.success(null);
    } catch (e, s) {
      return Result.failure(DatabaseError(
        message: 'JpnEsp単語ステータスの取得に失敗しました',
        originalError: e,
        stackTrace: s,
      ));
    }
  }

  @override
  Stream<JpnEspWordStatus> watchWordStatusById(int id) {
    return _local.watchWordStatusById(id).map((data) {
      if (data == null)
        throw Exception('JpnEsp word status not found for id: $id');
      return JpnEspWordStatusConverter.toEntity(data);
    });
  }

  @override
  Future<Result<List<JpnEspWordStatus>>> getLocalWordStatusAfter(
    DateTime datetime,
  ) async {
    try {
      final dataList = await _local.getWordStatusAfter(datetime);
      final entities = JpnEspWordStatusConverter.toEntityList(dataList);
      return Result.success(entities);
    } catch (e, s) {
      return Result.failure(DatabaseError(
        message: 'ローカルのJpnEsp単語ステータス一覧取得に失敗しました',
        originalError: e,
        stackTrace: s,
      ));
    }
  }

  @override
  Future<Result<JpnEspWordStatus?>> getLocalWordStatusById(int id) async {
    try {
      final data = await _local.getWordStatusById(id);
      if (data == null) {
        return Result.success(null);
      }
      return Result.success(JpnEspWordStatusConverter.toEntity(data));
    } catch (e, s) {
      return Result.failure(DatabaseError(
        message: 'ローカルのJpnEsp単語ステータス取得に失敗しました',
        originalError: e,
        stackTrace: s,
      ));
    }
  }

  @override
  Future<Result<List<JpnEspWordStatus>>> getRemoteWordStatusAfter(
    String userId,
    DateTime datetime,
  ) async {
    try {
      final dtoList = await _remote.getWordStatusAfter(userId, datetime);
      final entities = dtoList.map((dto) => dto.toDomain()).toList();
      return Result.success(entities);
    } on FirebaseException catch (e, s) {
      return Result.failure(FirebaseError(
        message: 'リモートのJpnEsp単語ステータス一覧取得に失敗しました: ${e.message}',
        code: e.code,
        originalError: e,
        stackTrace: s,
      ));
    } catch (e, s) {
      return Result.failure(UnexpectedError(
        message: 'リモートのJpnEsp単語ステータス一覧取得中に予期しないエラーが発生しました',
        originalError: e,
        stackTrace: s,
      ));
    }
  }

  @override
  Future<Result<JpnEspWordStatus?>> getRemoteWordStatusById(
    String userId,
    int id,
  ) async {
    try {
      final dto = await _remote.getWordStatusById(userId, id);
      if (dto == null) {
        return Result.success(null);
      }
      return Result.success(dto.toDomain());
    } on FirebaseException catch (e, s) {
      return Result.failure(FirebaseError(
        message: 'リモートのJpnEsp単語ステータス取得に失敗しました: ${e.message}',
        code: e.code,
        originalError: e,
        stackTrace: s,
      ));
    } catch (e, s) {
      return Result.failure(UnexpectedError(
        message: 'リモートのJpnEsp単語ステータス取得中に予期しないエラーが発生しました',
        originalError: e,
        stackTrace: s,
      ));
    }
  }

  @override
  Future<Result<void>> updateBatchRemoteWordStatus(
    List<JpnEspWordStatus> wordStatusList,
    String userId,
    DateTime? now,
  ) async {
    try {
      final dtoList = wordStatusList.map((w) {
        final updated = now != null ? w.copyWith(editAt: now) : w;
        return JpnEspWordStatusDTO.fromDomain(updated);
      }).toList();

      await _remote.updateWordStatusBatch(userId, dtoList);
      return const Result.success(null);
    } on FirebaseException catch (e, s) {
      return Result.failure(FirebaseError(
        message: 'リモートのJpnEsp単語ステータス一括更新に失敗しました: ${e.message}',
        code: e.code,
        originalError: e,
        stackTrace: s,
      ));
    } catch (e, s) {
      return Result.failure(UnexpectedError(
        message: 'リモートのJpnEsp単語ステータス一括更新中に予期しないエラーが発生しました',
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
