import 'dart:developer';

import 'package:my_dic/core/infrastructure/database/drift/database_provider.dart';
import 'package:my_dic/core/shared/enums/feature_tag.dart';
import 'package:my_dic/core/shared/errors/domain_errors.dart';
import 'package:my_dic/core/shared/errors/infrastructure_errors.dart';
import 'package:my_dic/core/shared/utils/result.dart';
import 'package:my_dic/features/my_word/domain/usecase/my_word/create/register_my_word/register_my_word_repository_input_data.dart';
import 'package:my_dic/features/my_word/domain/usecase/my_word/delete/delete_my_word/delete_my_word_repository_input_data.dart';
import 'package:my_dic/features/my_word/domain/usecase/my_word/update/update_my_word/update_my_word_repository_input_data.dart';
import 'package:my_dic/features/my_word/domain/usecase/update_my_word_status/update_my_word_status_repository_input_data.dart';
import 'package:my_dic/features/my_word/domain/entity/my_word.dart';
import 'package:my_dic/features/my_word/domain/i_repository/i_my_word_repository.dart';
import 'package:my_dic/features/my_word/domain/usecase/load_my_word/load_my_word_repository_input_data.dart';
import 'package:my_dic/features/my_word/data/data_source/local/i_my_word_local_data_source.dart';


class DriftMyWordRepository implements IMyWordRepository {
  final IMyWordLocalDataSource _dataSource;

  DriftMyWordRepository(this._dataSource);

  @override
  Future<Result<MyWord>> getById(int id) async {
    try {
      final res = await _dataSource.getMyWordById(id);
      if (res == null) {
        return Result.failure(NotFoundError(
          message: '指定された単語が見つかりません',
        ));
      }
      return Result.success(res);
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
        final res = await _dataSource.getFilteredMyWordByPage(input.size, input.offset);
        if (res == null) {
          return const Result.success([]);
        }
        return Result.success(res);
    } catch (e, s) {
      return Result.failure(DatabaseError(
        message: '単語リストの取得に失敗しました',
        originalError: e,
        stackTrace: s,
      ));
    }
  }

  @override
  Future<Result<void>> updateStatus(
      UpdateMyWordStatusRepositoryInputData input) async {
    try {
      log("updatestatusrepo");
      MyWordStatusTableData data = MyWordStatusTableData(
        myWordId: input.wordId,
        isLearned: input.status.contains(FeatureTag.isLearned) ? 1 : 0,
        isBookmarked: input.status.contains(FeatureTag.isBookmarked) ? 1 : 0,
        hasNote: input.status.contains(FeatureTag.hasNote) ? 1 : 0,
        editAt: input.editAt,
      );

      if (await _dataSource.existStatus(input.wordId)) {
        await _dataSource.updateStatus(data);
      } else {
        await _dataSource.insertStatus(data);
      }
      return const Result.success(null);
    } catch (e, s) {
      return Result.failure(DatabaseError(
        message: '単語ステータスの更新に失敗しました',
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

        final wordId = await _dataSource.insertMyWord(
          input.headword, input.description, input.dateTime);
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
      final affectedRows = await _dataSource.deleteMyword(input.id, input.dateTime);
      if (affectedRows == 0) {
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
        final affectedRows = await _dataSource.updateMyWord(
          input.myWordId, input.headword, input.description, input.editAt);

      if (affectedRows == 0) {
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
}
