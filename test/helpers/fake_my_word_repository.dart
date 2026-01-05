/// Fake implementation of IMyWordRepository for testing

import 'package:my_dic/core/shared/errors/domain_errors.dart';
import 'package:my_dic/core/shared/errors/infrastructure_errors.dart';
import 'package:my_dic/core/shared/utils/result.dart';
import 'package:my_dic/features/my_word/domain/entity/my_word.dart';
import 'package:my_dic/features/my_word/domain/i_repository/i_my_word_repository.dart';
import 'package:my_dic/features/my_word/domain/usecase/load_my_word/load_my_word_repository_input_data.dart';
import 'package:my_dic/features/my_word/domain/usecase/my_word/create/register_my_word/register_my_word_repository_input_data.dart';
import 'package:my_dic/features/my_word/domain/usecase/my_word/delete/delete_my_word/delete_my_word_repository_input_data.dart';
import 'package:my_dic/features/my_word/domain/usecase/my_word/update/update_my_word/update_my_word_repository_input_data.dart';
import 'package:my_dic/features/my_word/domain/usecase/update_my_word_status/update_my_word_status_repository_input_data.dart';

class FakeMyWordRepository implements IMyWordRepository {
  final Result<List<MyWord>>? _getFilteredResult;
  final Result<MyWord>? _getByIdResult;
  final Result<void>? _updateStatusResult;
  final Result<int>? _registerResult;
  final Result<void>? _updateResult;
  final Result<void>? _deleteResult;

  // Track calls for verification
  int getFilteredCallCount = 0;
  int? lastSize;
  int? lastOffset;

  FakeMyWordRepository({
    Result<List<MyWord>>? getFilteredResult,
    Result<MyWord>? getByIdResult,
    Result<void>? updateStatusResult,
    Result<int>? registerResult,
    Result<void>? updateResult,
    Result<void>? deleteResult,
  })  : _getFilteredResult = getFilteredResult,
        _getByIdResult = getByIdResult,
        _updateStatusResult = updateStatusResult,
        _registerResult = registerResult,
        _updateResult = updateResult,
        _deleteResult = deleteResult;

  // Factory: Success with sample data
  factory FakeMyWordRepository.success({List<MyWord>? words}) {
    final defaultWords = words ??
        [
          const MyWord(
            wordId: 1,
            word: 'hola',
            contents: 'こんにちは',
            isBookmarked: true,
          ),
          const MyWord(
            wordId: 2,
            word: 'gracias',
            contents: 'ありがとう',
            isLearned: true,
          ),
        ];

    return FakeMyWordRepository(
      getFilteredResult: Result.success(defaultWords),
      getByIdResult: Result.success(defaultWords.first),
      updateStatusResult: const Result.success(null),
      registerResult: const Result.success(123),
      updateResult: const Result.success(null),
      deleteResult: const Result.success(null),
    );
  }

  // Factory: Empty result
  factory FakeMyWordRepository.empty() {
    return FakeMyWordRepository(
      getFilteredResult: const Result.success([]),
    );
  }

  // Factory: Database error
  factory FakeMyWordRepository.databaseError() {
    return FakeMyWordRepository(
      getFilteredResult: Result.failure(
        DatabaseError(message: 'データベースエラー'),
      ),
    );
  }

  // Factory: Not found error
  factory FakeMyWordRepository.notFound() {
    return FakeMyWordRepository(
      getByIdResult: Result.failure(
        NotFoundError(message: '単語が見つかりません'),
      ),
    );
  }

  @override
  Future<Result<List<MyWord>>> getFilteredByPage(
    LoadMyWordRepositoryInputData input,
  ) async {
    getFilteredCallCount++;
    lastSize = input.size;
    lastOffset = input.offset;

    return _getFilteredResult ??
        Result.failure(
          DatabaseError(message: 'Not configured'),
        );
  }

  @override
  Future<Result<MyWord>> getById(int id) async {
    return _getByIdResult ??
        Result.failure(
          NotFoundError(message: 'Not found'),
        );
  }

  @override
  Future<Result<void>> updateStatus(
    UpdateMyWordStatusRepositoryInputData input,
  ) async {
    return _updateStatusResult ?? const Result.success(null);
  }

  @override
  Future<Result<int>> registerWord(
    RegisterMyWordRepositoryInputData input,
  ) async {
    return _registerResult ?? const Result.success(1);
  }

  @override
  Future<Result<void>> updateWord(
    UpdateMyWordRepositoryInputData input,
  ) async {
    return _updateResult ?? const Result.success(null);
  }

  @override
  Future<Result<void>> deleteWord(
    DeleteMyWordRepositoryInputData input,
  ) async {
    return _deleteResult ?? const Result.success(null);
  }
}
