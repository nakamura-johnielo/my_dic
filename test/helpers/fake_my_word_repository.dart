/// Fake implementation of MyWordRepository for testing.
library;

import 'package:my_dic/core/shared/errors/domain_errors.dart';
import 'package:my_dic/core/shared/errors/infrastructure_errors.dart';
import 'package:my_dic/core/shared/utils/result.dart';
import 'package:my_dic/features/my_word/internal/domain/entity/my_word.dart';
import 'package:my_dic/features/my_word/internal/domain/repository/my_word_repository.dart';
import 'package:my_dic/features/my_word/internal/domain/repository/delete_my_word_record.dart';
import 'package:my_dic/features/my_word/internal/domain/repository/my_word_page_query.dart';
import 'package:my_dic/features/my_word/internal/domain/repository/register_my_word_record.dart';
import 'package:my_dic/features/my_word/internal/domain/repository/update_my_word_record.dart';

class FakeMyWordRepository implements MyWordRepository {
  final Result<List<MyWord>>? _getFilteredResult;
  final Result<MyWord>? _getByIdResult;
  final Result<String>? _registerResult;
  final Result<void>? _updateResult;
  final Result<void>? _deleteResult;

  // Track calls for verification
  int getFilteredCallCount = 0;
  int? lastSize;
  int? lastOffset;

  FakeMyWordRepository({
    Result<List<MyWord>>? getFilteredResult,
    Result<MyWord>? getByIdResult,
    Result<String>? registerResult,
    Result<void>? updateResult,
    Result<void>? deleteResult,
  })  : _getFilteredResult = getFilteredResult,
        _getByIdResult = getByIdResult,
        _registerResult = registerResult,
        _updateResult = updateResult,
        _deleteResult = deleteResult;

  // Factory: Success with sample data
  factory FakeMyWordRepository.success({List<MyWord>? words}) {
    final defaultWords = words ??
        [
          MyWord(
            wordId: '1',
            word: 'hola',
            contents: 'こんにちは',
          ),
          MyWord(
            wordId: '2',
            word: 'gracias',
            contents: 'ありがとう',
          ),
        ];

    return FakeMyWordRepository(
      getFilteredResult: Result.success(defaultWords),
      getByIdResult: Result.success(defaultWords.first),
      registerResult: const Result.success('123'),
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
      MyWordPageQuery input,
      {required String accountId}) async {
    getFilteredCallCount++;
    lastSize = input.size;
    lastOffset = input.offset;

    return _getFilteredResult ??
        Result.failure(
          DatabaseError(message: 'Not configured'),
        );
  }

  @override
  Future<Result<MyWord>> getById(String id, {required String accountId}) async {
    return _getByIdResult ??
        Result.failure(
          NotFoundError(message: 'Not found'),
        );
  }

  @override
  Future<Result<String>> registerWord(
    RegisterMyWordRecord input,
  ) async {
    return _registerResult ?? const Result.success('1');
  }

  @override
  Future<Result<void>> updateWord(
    UpdateMyWordRecord input,
  ) async {
    return _updateResult ?? const Result.success(null);
  }

  @override
  Future<Result<void>> deleteWord(
    DeleteMyWordRecord input,
  ) async {
    return _deleteResult ?? const Result.success(null);
  }

  @override
  Future<Result<List<String>>> getIdsFilteredByPage(
    MyWordPageQuery input, {
    required String accountId,
  }) async =>
      const Result.success([]);

  @override
  Stream<MyWord> watchMyWord(String id, {required String accountId}) =>
      const Stream.empty();
}
