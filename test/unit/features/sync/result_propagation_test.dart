import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:my_dic/core/domain/entity/sync_checkpoint.dart';
import 'package:my_dic/core/domain/i_repository/i_sync_status_repository.dart';
import 'package:my_dic/core/shared/errors/domain_errors.dart';
import 'package:my_dic/core/shared/errors/infrastructure_errors.dart';
import 'package:my_dic/core/shared/utils/result.dart';
import 'package:my_dic/features/auth/domain/I_repository/i_auth_repository.dart';
import 'package:my_dic/features/auth/domain/entity/app_auth.dart';
import 'package:my_dic/features/my_word/domain/entity/my_word.dart';
import 'package:my_dic/features/my_word/domain/i_repository/i_my_word_repository.dart';
import 'package:my_dic/features/my_word/domain/i_repository/i_my_word_status_repository.dart';
import 'package:my_dic/features/my_word/domain/usecase/my_word/sync_my_word/sync_my_word_interactor copy.dart';
import 'package:my_dic/features/my_word/domain/usecase/my_word_status/sync_myword_status/sync_myword_status_usecase.dart';
import 'package:my_dic/features/my_word/domain/usecase/my_word_status/update_my_word_status/update_my_word_status_interactor.dart';
import 'package:my_dic/features/my_word/domain/usecase/my_word_status/update_my_word_status/update_my_word_status_repository_input_data.dart';
import 'package:my_dic/features/my_word/presentation/ui_model/my_word_status_command_event.dart';
import 'package:my_dic/features/my_word/presentation/view_model/my_word_status_command.dart';

import '../../../helpers/fake_current_session.dart';

class _MockAuthRepository extends Mock implements IAuthRepository {}

class _MockMyWordRepository extends Mock implements IMyWordRepository {}

class _MockMyWordStatusRepository extends Mock
    implements IMyWordStatusRepository {}

class _MemorySyncStatusRepository implements ISyncStatusRepository {
  _MemorySyncStatusRepository({this.getResult});

  final Result<SyncCheckpoint?>? getResult;
  int saveCount = 0;

  @override
  Future<Result<SyncCheckpoint?>> getCheckpoint(SyncCheckpointKey key) async {
    return getResult ?? const Result.success(null);
  }

  @override
  Future<Result<void>> saveCheckpoint(SyncCheckpoint checkpoint) async {
    saveCount++;
    return const Result.success(null);
  }
}

void main() {
  const accountId = 'account-a';
  final authenticated = AppAuth(
    accountId: accountId,
    isLogined: true,
    isAuthenticated: true,
  );

  setUpAll(() {
    registerFallbackValue(UpdateMyWordStatusRepositoryInputData(
      'fallback',
      null,
      null,
      null,
      DateTime.utc(2026),
      null,
    ));
  });

  test('status repository failure reaches the command as a failed event',
      () async {
    final currentSession = FakeCurrentSession(accountIdOrNull: accountId);
    final statusRepository = _MockMyWordStatusRepository();
    final error = DatabaseError(message: 'status write failed');
    when(() => statusRepository.updateStatus(any()))
        .thenAnswer((_) async => Result.failure(error));
    final interactor =
        UpdateMyWordStatusInteractor(statusRepository, currentSession);
    final command = MyWordStatusCommand('word-1', interactor);

    command.toggleBookmark(false);
    await Future<void>.delayed(Duration.zero);

    expect(command.state, isA<ToggleBookmarkedFailed>());
    verify(() => statusRepository.updateStatus(any())).called(1);
  });

  test('MyWord local lookup failure is propagated and does not create',
      () async {
    final authRepository = _MockAuthRepository();
    final repository = _MockMyWordRepository();
    final error = DatabaseError(message: 'local lookup failed');
    final remote = MyWord(
      wordId: 'word-1',
      word: 'hola',
      contents: 'hello',
      editAt: DateTime.utc(2026, 8, 1),
    );
    when(() => authRepository.getCurrentAuth())
        .thenAnswer((_) async => Result.success(authenticated));
    when(() => repository.getRemoteMyWordById(accountId, remote.wordId))
        .thenAnswer((_) async => Result.success(remote));
    when(() => repository.getLocalMyWordById(remote.wordId))
        .thenAnswer((_) async => Result.failure(error));
    final useCase = SyncMyWordInteractor(
      _MemorySyncStatusRepository(),
      repository,
      authRepository,
    );

    final result = await useCase.syncOnUpdatedRemote(remote.wordId);

    expect(result.errorOrNull, same(error));
    verifyNever(() => repository.createLocalMyWord(remote));
  });

  test('MyWord success(null) alone selects the create path', () async {
    final authRepository = _MockAuthRepository();
    final repository = _MockMyWordRepository();
    final remote = MyWord(
      wordId: 'word-1',
      word: 'hola',
      contents: 'hello',
      editAt: DateTime.utc(2026, 8, 1),
    );
    when(() => authRepository.getCurrentAuth())
        .thenAnswer((_) async => Result.success(authenticated));
    when(() => repository.getRemoteMyWordById(accountId, remote.wordId))
        .thenAnswer((_) async => Result.success(remote));
    when(() => repository.getLocalMyWordById(remote.wordId))
        .thenAnswer((_) async => const Result.success(null));
    when(() => repository.createLocalMyWord(remote))
        .thenAnswer((_) async => const Result.success(null));
    final useCase = SyncMyWordInteractor(
      _MemorySyncStatusRepository(),
      repository,
      authRepository,
    );

    final result = await useCase.syncOnUpdatedRemote(remote.wordId);

    expect(result.isSuccess, isTrue);
    verify(() => repository.createLocalMyWord(remote)).called(1);
  });

  test('MyWord NotFound failure is not reinterpreted as success(null)',
      () async {
    final authRepository = _MockAuthRepository();
    final repository = _MockMyWordRepository();
    final error = NotFoundError(message: 'contract violation');
    final remote = MyWord(
      wordId: 'word-1',
      word: 'hola',
      contents: 'hello',
      editAt: DateTime.utc(2026, 8, 1),
    );
    when(() => authRepository.getCurrentAuth())
        .thenAnswer((_) async => Result.success(authenticated));
    when(() => repository.getRemoteMyWordById(accountId, remote.wordId))
        .thenAnswer((_) async => Result.success(remote));
    when(() => repository.getLocalMyWordById(remote.wordId))
        .thenAnswer((_) async => Result.failure(error));
    final useCase = SyncMyWordInteractor(
      _MemorySyncStatusRepository(),
      repository,
      authRepository,
    );

    final result = await useCase.syncOnUpdatedRemote(remote.wordId);

    expect(result.errorOrNull, same(error));
    verifyNever(() => repository.createLocalMyWord(remote));
  });

  test('MyWord list failure does not reach dataOrNull and blocks checkpoint',
      () async {
    final authRepository = _MockAuthRepository();
    final repository = _MockMyWordRepository();
    final checkpoints = _MemorySyncStatusRepository();
    final error = DatabaseError(message: 'local list failed');
    when(() => authRepository.getCurrentAuth())
        .thenAnswer((_) async => Result.success(authenticated));
    when(() => repository.getRemoteMyWordsAfter(accountId, any()))
        .thenAnswer((_) async => const Result.success([]));
    when(() => repository.getLocalMyWordsAfter(any()))
        .thenAnswer((_) async => Result.failure(error));
    final useCase =
        SyncMyWordInteractor(checkpoints, repository, authRepository);

    final result = await useCase.syncOnce();

    expect(result.errorOrNull, same(error));
    expect(checkpoints.saveCount, 0);
  });

  test('authentication repository failure is propagated by sync', () async {
    final authRepository = _MockAuthRepository();
    final repository = _MockMyWordRepository();
    final error = BusinessRuleError(message: 'auth unavailable');
    when(() => authRepository.getCurrentAuth())
        .thenAnswer((_) async => Result.failure(error));
    final useCase = SyncMyWordInteractor(
      _MemorySyncStatusRepository(),
      repository,
      authRepository,
    );

    final result = await useCase.syncOnce();

    expect(result.errorOrNull, same(error));
    verifyNever(() => repository.getRemoteMyWordsAfter(any(), any()));
  });

  test('checkpoint repository failure is propagated before remote queries',
      () async {
    final authRepository = _MockAuthRepository();
    final repository = _MockMyWordRepository();
    final error = DatabaseError(message: 'checkpoint unavailable');
    final checkpoints = _MemorySyncStatusRepository(
      getResult: Result.failure(error),
    );
    when(() => authRepository.getCurrentAuth())
        .thenAnswer((_) async => Result.success(authenticated));
    final useCase =
        SyncMyWordInteractor(checkpoints, repository, authRepository);

    final result = await useCase.syncOnce();

    expect(result.errorOrNull, same(error));
    verifyNever(() => repository.getRemoteMyWordsAfter(any(), any()));
    expect(checkpoints.saveCount, 0);
  });

  test('MyWordStatus list failure is propagated without a null assertion',
      () async {
    final authRepository = _MockAuthRepository();
    final repository = _MockMyWordStatusRepository();
    final checkpoints = _MemorySyncStatusRepository();
    final error = DatabaseError(message: 'local status list failed');
    when(() => authRepository.getCurrentAuth())
        .thenAnswer((_) async => Result.success(authenticated));
    when(() => repository.getRemoteStatusAfter(accountId, any()))
        .thenAnswer((_) async => const Result.success([]));
    when(() => repository.getLocalStatusAfter(any()))
        .thenAnswer((_) async => Result.failure(error));
    final useCase =
        SyncMyWordStatusUsecase(checkpoints, repository, authRepository);

    final result = await useCase.syncOnce();

    expect(result.errorOrNull, same(error));
    expect(checkpoints.saveCount, 0);
  });
}
