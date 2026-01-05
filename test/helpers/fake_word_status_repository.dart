/// Fake implementation of IWordStatusRepository for testing
/// Demonstrates local + remote sync logic testing

import 'package:my_dic/features/esp_jpn_word_status/domain/esp_word_status.dart';
import 'package:my_dic/features/esp_jpn_word_status/domain/i_word_status_repository.dart';
import 'package:my_dic/core/shared/errors/infrastructure_errors.dart';
import 'package:my_dic/core/shared/utils/result.dart';

class FakeWordStatusRepository implements IWordStatusRepository {
  final Result<void>? _localUpdateResult;
  final Result<void>? _remoteUpdateResult;
  final Result<WordStatus?>? _getByIdResult;
  final Result<void>? _deleteResult;

  // Track calls for verification
  int localUpdateCallCount = 0;
  int remoteUpdateCallCount = 0;
  WordStatus? lastLocalWordStatus;
  WordStatus? lastRemoteWordStatus;
  String? lastUserId;

  FakeWordStatusRepository({
    Result<void>? localUpdateResult,
    Result<void>? remoteUpdateResult,
    Result<WordStatus?>? getByIdResult,
    Result<void>? deleteResult,
  })  : _localUpdateResult = localUpdateResult,
        _remoteUpdateResult = remoteUpdateResult,
        _getByIdResult = getByIdResult,
        _deleteResult = deleteResult;

  // Factory: Both local and remote succeed
  factory FakeWordStatusRepository.success() {
    return FakeWordStatusRepository(
      localUpdateResult: const Result.success(null),
      remoteUpdateResult: const Result.success(null),
    );
  }

  // Factory: Local update fails
  factory FakeWordStatusRepository.localFailure() {
    return FakeWordStatusRepository(
      localUpdateResult: Result.failure(
        DatabaseError(message: 'ローカルDB更新に失敗しました'),
      ),
    );
  }

  // Factory: Remote update fails (but local succeeds)
  factory FakeWordStatusRepository.remoteFailure() {
    return FakeWordStatusRepository(
      localUpdateResult: const Result.success(null),
      remoteUpdateResult: Result.failure(
        NetworkError(message: 'リモート更新に失敗しました'),
      ),
    );
  }

  @override
  Future<Result<void>> updateWordStatus(
    WordStatus wordStatus,
    DateTime now,
    String userId,
  ) async {
    return const Result.success(null);
  }

  @override
  Future<Result<void>> updateLocalWordStatus(
    WordStatus wordStatus,
    DateTime now,
    String userId,
  ) async {
    localUpdateCallCount++;
    lastLocalWordStatus = wordStatus;
    lastUserId = userId;

    return _localUpdateResult ?? const Result.success(null);
  }

  @override
  Future<Result<void>> updateRemoteWordStatus(
    WordStatus wordStatus,
    String userId,
    DateTime? now,
  ) async {
    remoteUpdateCallCount++;
    lastRemoteWordStatus = wordStatus;
    lastUserId = userId;

    return _remoteUpdateResult ?? const Result.success(null);
  }

  @override
  Future<Result<WordStatus?>> getWordStatusById(int id) async {
    return _getByIdResult ??
        Result.success(
          WordStatus(wordId: id, isBookmarked: false, isLearned: false),
        );
  }

  @override
  Future<Result<void>> deleteWordStatus(WordStatus wordStatus) async {
    return _deleteResult ?? const Result.success(null);
  }

  @override
  Stream<WordStatus> watchWordStatusById(int id) {
    return Stream.value(
      WordStatus(wordId: id, isBookmarked: false, isLearned: false),
    );
  }

  @override
  Future<Result<List<WordStatus>>> getRemoteWordStatusAfter(
    String userId,
    DateTime datetime,
  ) async {
    return Result.success([]);
  }

  @override
  Future<Result<WordStatus?>> getRemoteWordStatusById(
    String userId,
    int id,
  ) async {
    return Result.success(null);
  }

  @override
  Future<Result<List<WordStatus>>> getLocalWordStatusAfter(
    DateTime datetime,
  ) async {
    return Result.success([]);
  }

  @override
  Future<Result<WordStatus?>> getLocalWordStatusById(int id) async {
    return Result.success(null);
  }

  @override
  Future<Result<void>> updateBatchRemoteWordStatus(
    List<WordStatus> wordStatusList,
    String userId,
    DateTime? now,
  ) async {
    return const Result.success(null);
  }

  @override
  Stream<List<int>> watchRemoteChangedIds(String userId) {
    return Stream.value([]);
  }

  @override
  Stream<List<int>> watchLocalChangedIds(DateTime datetime) {
    return Stream.value([]);
  }
}
