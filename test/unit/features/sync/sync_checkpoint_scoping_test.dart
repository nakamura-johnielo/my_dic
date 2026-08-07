import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:my_dic/core/domain/entity/sync_checkpoint.dart';
import 'package:my_dic/core/domain/i_repository/i_sync_status_repository.dart';
import 'package:my_dic/core/shared/errors/domain_errors.dart';
import 'package:my_dic/core/shared/utils/result.dart';
import 'package:my_dic/features/auth/domain/I_repository/i_auth_repository.dart';
import 'package:my_dic/features/auth/domain/entity/app_auth.dart';
import 'package:my_dic/features/my_word/domain/entity/my_word.dart';
import 'package:my_dic/features/my_word/domain/i_repository/i_my_word_repository.dart';
import 'package:my_dic/features/my_word/domain/i_repository/i_my_word_status_repository.dart';
import 'package:my_dic/features/my_word/domain/usecase/my_word/sync_my_word/sync_my_word_interactor_copy.dart';
import 'package:my_dic/features/my_word/domain/usecase/my_word_status/sync_myword_status/sync_myword_status_usecase.dart';
import 'package:my_dic/features/sync/sync_service.dart';

class _MockAuthRepository extends Mock implements IAuthRepository {}

class _MockMyWordRepository extends Mock implements IMyWordRepository {}

class _MockMyWordStatusRepository extends Mock
    implements IMyWordStatusRepository {}

class _MemorySyncStatusRepository implements ISyncStatusRepository {
  final checkpoints = <SyncCheckpointKey, SyncCheckpoint>{};

  @override
  Future<Result<SyncCheckpoint?>> getCheckpoint(SyncCheckpointKey key) async {
    return Result.success(checkpoints[key]);
  }

  @override
  Future<Result<void>> saveCheckpoint(SyncCheckpoint checkpoint) async {
    checkpoints[checkpoint.key] = checkpoint;
    return const Result.success(null);
  }
}

void main() {
  const accountId = 'account-a';
  final myWordKey = SyncCheckpointKey(
    accountId: accountId,
    dataset: SyncDataset.myWords,
  );
  final statusKey = SyncCheckpointKey(
    accountId: accountId,
    dataset: SyncDataset.myWordStatus,
  );
  final oldMyWordDate = DateTime.utc(2026, 7, 1);
  final oldStatusDate = DateTime.utc(2026, 6, 1);

  late _MockAuthRepository authRepository;
  late _MockMyWordRepository myWordRepository;
  late _MockMyWordStatusRepository statusRepository;
  late _MemorySyncStatusRepository checkpointRepository;

  setUp(() {
    authRepository = _MockAuthRepository();
    myWordRepository = _MockMyWordRepository();
    statusRepository = _MockMyWordStatusRepository();
    checkpointRepository = _MemorySyncStatusRepository();
    checkpointRepository.checkpoints[myWordKey] = SyncCheckpoint(
      key: myWordKey,
      lastSuccessfulAt: oldMyWordDate,
    );
    checkpointRepository.checkpoints[statusKey] = SyncCheckpoint(
      key: statusKey,
      lastSuccessfulAt: oldStatusDate,
    );

    when(() => authRepository.getCurrentAuth()).thenAnswer(
      (_) async => Result.success(AppAuth(
        accountId: accountId,
        isLogined: true,
        isAuthenticated: true,
      )),
    );
  });

  test('successful dataset advances while failed dataset keeps its checkpoint',
      () async {
    when(() => myWordRepository.getRemoteMyWordsAfter(
          accountId,
          oldMyWordDate,
        )).thenAnswer((_) async => const Result.success([]));
    when(() => myWordRepository.getLocalMyWordsAfter(oldMyWordDate))
        .thenAnswer((_) async => const Result.success([]));
    when(() => statusRepository.getRemoteStatusAfter(
          accountId,
          oldStatusDate,
        )).thenAnswer(
      (_) async => Result.failure(
        BusinessRuleError(message: 'status sync failed'),
      ),
    );
    final service = SyncService([
      SyncMyWordInteractor(
        checkpointRepository,
        myWordRepository,
        authRepository,
      ),
      SyncMyWordStatusUsecase(
        checkpointRepository,
        statusRepository,
        authRepository,
      ),
    ]);

    await service.syncOnceAll();

    expect(
      checkpointRepository.checkpoints[myWordKey]!.lastSuccessfulAt
          .isAfter(oldMyWordDate),
      isTrue,
    );
    expect(
      checkpointRepository.checkpoints[statusKey]!.lastSuccessfulAt,
      oldStatusDate,
    );

    // A retry of the failed dataset reads the same range again.
    final retry = SyncMyWordStatusUsecase(
      checkpointRepository,
      statusRepository,
      authRepository,
    );
    await retry.syncOnce();
    verify(() => statusRepository.getRemoteStatusAfter(
          accountId,
          oldStatusDate,
        )).called(2);
  });

  test('item failure prevents checkpoint commit', () async {
    final remoteItem = MyWord(
      wordId: 'word-1',
      word: 'hola',
      contents: 'hello',
      editAt: DateTime.utc(2026, 7, 2),
    );
    when(() => myWordRepository.getRemoteMyWordsAfter(
          accountId,
          oldMyWordDate,
        )).thenAnswer((_) async => Result.success([remoteItem]));
    when(() => myWordRepository.getLocalMyWordById('word-1'))
        .thenAnswer((_) async => const Result.success(null));
    when(() => myWordRepository.createLocalMyWord(remoteItem)).thenAnswer(
      (_) async => Result.failure(
        BusinessRuleError(message: 'local write failed'),
      ),
    );
    final useCase = SyncMyWordInteractor(
      checkpointRepository,
      myWordRepository,
      authRepository,
    );

    final result = await useCase.syncOnce();

    expect(result.isFailure, isTrue);
    expect(
      checkpointRepository.checkpoints[myWordKey]!.lastSuccessfulAt,
      oldMyWordDate,
    );
  });

  test('single item event does not advance the full-sync checkpoint', () async {
    final remoteItem = MyWord(
      wordId: 'word-1',
      word: 'hola',
      contents: 'hello',
      editAt: DateTime.utc(2026, 7, 2),
    );
    when(() => myWordRepository.getRemoteMyWordById(accountId, 'word-1'))
        .thenAnswer((_) async => Result.success(remoteItem));
    when(() => myWordRepository.getLocalMyWordById('word-1'))
        .thenAnswer((_) async => const Result.success(null));
    when(() => myWordRepository.createLocalMyWord(remoteItem))
        .thenAnswer((_) async => const Result.success(null));
    final useCase = SyncMyWordInteractor(
      checkpointRepository,
      myWordRepository,
      authRepository,
    );

    final result = await useCase.syncOnUpdatedRemote('word-1');

    expect(result.isSuccess, isTrue);
    expect(
      checkpointRepository.checkpoints[myWordKey]!.lastSuccessfulAt,
      oldMyWordDate,
    );
  });
}
