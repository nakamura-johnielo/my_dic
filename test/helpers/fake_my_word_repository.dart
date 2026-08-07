/// Fake implementation of IMyWordRepository for testing

import 'package:my_dic/core/shared/errors/domain_errors.dart';
import 'package:my_dic/core/shared/errors/infrastructure_errors.dart';
import 'package:my_dic/core/shared/utils/result.dart';
import 'package:my_dic/features/my_word/domain/entity/my_word.dart';
import 'package:my_dic/features/my_word/domain/i_repository/i_my_word_repository.dart';
import 'package:my_dic/features/my_word/domain/usecase/my_word/load_my_word/load_my_word_repository_input_data.dart';
import 'package:my_dic/features/my_word/domain/usecase/my_word/create/register_my_word/register_my_word_repository_input_data.dart';
import 'package:my_dic/features/my_word/domain/usecase/my_word/delete/delete_my_word/delete_my_word_repository_input_data.dart';
import 'package:my_dic/features/my_word/domain/usecase/my_word/update/update_my_word/update_my_word_repository_input_data.dart';
import 'package:my_dic/features/my_word/domain/usecase/my_word_status/update_my_word_status/update_my_word_status_repository_input_data.dart';

class FakeMyWordRepository implements IMyWordRepository {
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
            isBookmarked: true,
          ),
          MyWord(
            wordId: '2',
            word: 'gracias',
            contents: 'ありがとう',
            isLearned: true,
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
      LoadMyWordRepositoryInputData input,
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
  @override
  Future<Result<String>> registerWord(
    RegisterMyWordRepositoryInputData input,
  ) async {
    return _registerResult ?? const Result.success('1');
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

  @override
  Future<Result<List<String>>> getIdsFilteredByPage(
    LoadMyWordRepositoryInputData input, {
    required String accountId,
  }) async =>
      const Result.success([]);

  @override
  Future<Result<List<MyWord>>> getRemoteMyWordsAfter(
          String userId, DateTime datetime) async =>
      const Result.success([]);

  @override
  Future<Result<MyWord?>> getRemoteMyWordById(
          String userId, String myWordId) async =>
      const Result.success(null);

  @override
  Future<Result<void>> updateRemoteMyWord(
          String userId, MyWord myWord, DateTime? now) async =>
      const Result.success(null);

  @override
  Future<Result<void>> updateBatchRemoteMyWords(
          String userId, List<MyWord> myWordList) async =>
      const Result.success(null);

  @override
  Future<Result<void>> deleteRemoteMyWord(
          String userId, String myWordId) async =>
      const Result.success(null);

  @override
  Future<Result<List<MyWord>>> getLocalMyWordsAfter(DateTime datetime) async =>
      const Result.success([]);

  @override
  Future<Result<MyWord?>> getLocalMyWordById(String myWordId) async =>
      const Result.success(null);

  @override
  Future<Result<void>> updateLocalMyWord(MyWord myWord, DateTime now) async =>
      const Result.success(null);

  @override
  Future<Result<void>> createLocalMyWord(MyWord myWord) async =>
      const Result.success(null);

  @override
  Stream<List<String>> watchRemoteChangedIds(String userId) =>
      const Stream.empty();

  @override
  Stream<List<String>> watchLocalChangedIds(DateTime datetime) =>
      const Stream.empty();

  @override
  Stream<MyWord> watchMyWord(String id, {required String accountId}) =>
      const Stream.empty();
}
