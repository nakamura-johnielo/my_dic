import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:my_dic/app/guest_migration/migrate_guest_data_usecase.dart';
import 'package:my_dic/core/infrastructure/database/drift/database_provider.dart';
import 'package:my_dic/core/shared/consts/account_scope.dart';
import 'package:my_dic/features/sync/port/sync_dataset.dart';
import 'package:my_dic/features/my_word/internal/infrastructure/data/data_source/local/drift_my_word_dao.dart';
import 'package:my_dic/features/my_word/internal/infrastructure/data/data_source/local/drift_my_word_status_dao.dart';
import 'package:my_dic/features/my_word/internal/infrastructure/data/data_source/local/my_word_drift_data_source.dart';
import 'package:my_dic/features/my_word/internal/infrastructure/data/data_source/local/my_word_status_drift_data_source.dart';
import 'package:my_dic/features/my_word/internal/infrastructure/guest_migration/my_word_guest_migration_adapter.dart';
import 'package:my_dic/features/sync/port/model/sync_mutation.dart';
import 'package:my_dic/features/sync/internal/application/in_memory_session_fence.dart';
import 'package:my_dic/features/sync/port/outbox_writer.dart';
import 'package:my_dic/features/user_profile/internal/infrastructure/local/drift_user_profile_dao.dart';
import 'package:my_dic/features/user_profile/internal/infrastructure/local/user_profile_drift_data_source.dart';
import 'package:my_dic/features/user_profile/internal/infrastructure/user_profile_guest_migration_adapter.dart';
import 'package:my_dic/features/word_status/internal/infrastructure/esp_jpn/drift/esp_jpn_word_status_local_data_source.dart';
import 'package:my_dic/features/word_status/internal/infrastructure/guest_migration/drift_word_status_guest_migration.dart';
import 'package:my_dic/features/word_status/internal/infrastructure/jpn_esp/drift/jpn_esp_word_status_local_data_source.dart';

class _EspJpnStatus extends Mock implements EspJpnWordStatusLocalDataSource {}

class _JpnEspStatus extends Mock implements JpnEspWordStatusLocalDataSource {}

class _OutboxWriter extends Mock implements OutboxWriter {}

class _SyncMutationFake extends Fake implements SyncMutation {}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  setUpAll(() => registerFallbackValue(_SyncMutationFake()));

  test('moves a guest MyWord and merges its status exactly once', () async {
    final database = DatabaseProvider.forTesting(NativeDatabase.memory());
    addTearDown(database.close);
    final myWord = MyWordDriftDataSource(MyWordDao(database));
    final myWordStatus = MyWordStatusDriftDataSource(MyWordStatusDao(database));
    final userProfile = UserProfileDriftDataSource(UserProfileDao(database));
    final userProfilePort = UserProfileGuestMigrationAdapter(userProfile);
    final espJpn = _EspJpnStatus();
    final jpnEsp = _JpnEspStatus();
    final outbox = _OutboxWriter();
    final fence = InMemorySessionFence()..setCurrent('account-a', 1);
    when(() => espJpn.getWordStatusAfter(any(), any()))
        .thenAnswer((_) async => []);
    when(() => jpnEsp.getWordStatusAfter(any(), any()))
        .thenAnswer((_) async => []);
    when(() => outbox.enqueue(any())).thenAnswer((_) async {});

    await myWord.insertMyWordWithRevision(
      id: 'guest-word',
      word: 'hola',
      contents: 'hello',
      editAt: DateTime.utc(2026, 8, 6).toIso8601String(),
      accountId: guestAccountScope,
    );
    await myWordStatus.applyStatusPatch(
      'guest-word',
      1,
      0,
      1,
      DateTime.utc(2026, 8, 6).toIso8601String(),
      guestAccountScope,
    );

    final useCase = MigrateGuestDataUseCase(
      database: database,
      wordStatus: DriftWordStatusGuestMigration(
        espJpn: espJpn,
        jpnEsp: jpnEsp,
        outboxWriter: outbox,
      ),
      myWord: MyWordGuestMigrationAdapter(myWord, myWordStatus, outbox),
      userProfile: userProfilePort,
      outboxWriter: outbox,
      sessionFence: fence,
      clock: () => DateTime.utc(2026, 8, 7),
    );

    await useCase.execute('account-a', 1);

    expect(await myWord.getMyWordById('guest-word', guestAccountScope), isNull);
    expect(await myWord.getMyWordById('guest-word', 'account-a'), isNotNull);
    expect(await myWordStatus.getWordStatus('guest-word', guestAccountScope),
        isNull);
    final migratedStatus =
        await myWordStatus.getWordStatus('guest-word', 'account-a');
    expect(migratedStatus?.isLearned, 1);
    expect(migratedStatus?.hasNote, 1);
    verify(() => outbox.enqueue(any())).called(2);

    clearInteractions(outbox);
    await useCase.execute('account-a', 1);
    verifyNever(() => outbox.enqueue(any()));
  });

  test('reports MyWord aggregate guest counts through the public port',
      () async {
    final database = DatabaseProvider.forTesting(NativeDatabase.memory());
    addTearDown(database.close);
    final myWord = MyWordDriftDataSource(MyWordDao(database));
    final myWordStatus = MyWordStatusDriftDataSource(MyWordStatusDao(database));
    final outbox = _OutboxWriter();
    await myWord.insertMyWordWithRevision(
      id: 'guest-word',
      word: 'hola',
      contents: 'hello',
      editAt: DateTime.utc(2026, 8, 6).toIso8601String(),
      accountId: guestAccountScope,
    );
    await myWordStatus.applyStatusPatch(
      'guest-word',
      1,
      0,
      0,
      DateTime.utc(2026, 8, 6).toIso8601String(),
      guestAccountScope,
    );

    final counts = await MyWordGuestMigrationAdapter(
      myWord,
      myWordStatus,
      outbox,
    ).countGuestRows();

    expect(counts.words, 1);
    expect(counts.statuses, 1);
  });

  test('preserves a colliding MyWord and its guest status pair', () async {
    final database = DatabaseProvider.forTesting(NativeDatabase.memory());
    addTearDown(database.close);
    final myWord = MyWordDriftDataSource(MyWordDao(database));
    final myWordStatus = MyWordStatusDriftDataSource(MyWordStatusDao(database));
    final userProfile = UserProfileDriftDataSource(UserProfileDao(database));
    final espJpn = _EspJpnStatus();
    final jpnEsp = _JpnEspStatus();
    final outbox = _OutboxWriter();
    when(() => espJpn.getWordStatusAfter(any(), any()))
        .thenAnswer((_) async => []);
    when(() => jpnEsp.getWordStatusAfter(any(), any()))
        .thenAnswer((_) async => []);
    when(() => outbox.enqueue(any())).thenAnswer((_) async {});
    for (final accountId in [guestAccountScope, 'account-a']) {
      await myWord.insertMyWordWithRevision(
        id: 'same-id',
        word: accountId == guestAccountScope ? 'guest' : 'account',
        contents: 'contents',
        editAt: DateTime.utc(2026, 8, 6).toIso8601String(),
        accountId: accountId,
      );
    }
    await myWordStatus.applyStatusPatch(
      'same-id',
      1,
      0,
      1,
      DateTime.utc(2026, 8, 6).toIso8601String(),
      guestAccountScope,
    );

    await MigrateGuestDataUseCase(
      database: database,
      wordStatus: DriftWordStatusGuestMigration(
        espJpn: espJpn,
        jpnEsp: jpnEsp,
        outboxWriter: outbox,
      ),
      myWord: MyWordGuestMigrationAdapter(myWord, myWordStatus, outbox),
      userProfile: UserProfileGuestMigrationAdapter(userProfile),
      outboxWriter: outbox,
      sessionFence: InMemorySessionFence()..setCurrent('account-a', 1),
    ).execute('account-a', 1);

    expect(await myWord.getMyWordById('same-id', guestAccountScope), isNotNull);
    expect(await myWordStatus.getWordStatus('same-id', guestAccountScope),
        isNotNull);
    expect(
        (await myWord.getMyWordById('same-id', 'account-a'))?.word, 'account');
    verifyNever(() => outbox.enqueue(any()));
  });

  test('imports a guest profile only when the account has no username',
      () async {
    final database = DatabaseProvider.forTesting(NativeDatabase.memory());
    addTearDown(database.close);
    final myWord = MyWordDriftDataSource(MyWordDao(database));
    final myWordStatus = MyWordStatusDriftDataSource(MyWordStatusDao(database));
    final userProfile = UserProfileDriftDataSource(UserProfileDao(database));
    final userProfilePort = UserProfileGuestMigrationAdapter(userProfile);
    final espJpn = _EspJpnStatus();
    final jpnEsp = _JpnEspStatus();
    final outbox = _OutboxWriter();
    final fence = InMemorySessionFence()..setCurrent('account-a', 1);
    when(() => espJpn.getWordStatusAfter(any(), any()))
        .thenAnswer((_) async => []);
    when(() => jpnEsp.getWordStatusAfter(any(), any()))
        .thenAnswer((_) async => []);
    when(() => outbox.enqueue(any())).thenAnswer((_) async {});
    await userProfile
        .upsertProfileFields(guestAccountScope, {'username': 'Guest name'});

    final useCase = MigrateGuestDataUseCase(
      database: database,
      wordStatus: DriftWordStatusGuestMigration(
        espJpn: espJpn,
        jpnEsp: jpnEsp,
        outboxWriter: outbox,
      ),
      myWord: MyWordGuestMigrationAdapter(myWord, myWordStatus, outbox),
      userProfile: userProfilePort,
      outboxWriter: outbox,
      sessionFence: fence,
    );

    await useCase.execute('account-a', 1);

    expect(await userProfile.getProfile(guestAccountScope), isNull);
    expect(await userProfile.getUsername('account-a'), 'Guest name');
    final captured = verify(() => outbox.enqueue(captureAny())).captured;
    final profileMutation = captured.cast<SyncMutation>().singleWhere(
          (mutation) => mutation.dataset == SyncDataset.userProfile,
        );
    expect(profileMutation.mutationId, contains(':user_profile:account-a'));

    clearInteractions(outbox);
    await useCase.execute('account-a', 1);
    verifyNever(() => outbox.enqueue(any()));
  });

  test('rolls back migrated rows when the session changes before commit',
      () async {
    final database = DatabaseProvider.forTesting(NativeDatabase.memory());
    addTearDown(database.close);
    final myWord = MyWordDriftDataSource(MyWordDao(database));
    final myWordStatus = MyWordStatusDriftDataSource(MyWordStatusDao(database));
    final userProfile = UserProfileDriftDataSource(UserProfileDao(database));
    final userProfilePort = UserProfileGuestMigrationAdapter(userProfile);
    final espJpn = _EspJpnStatus();
    final jpnEsp = _JpnEspStatus();
    final outbox = _OutboxWriter();
    final fence = InMemorySessionFence()..setCurrent('account-a', 1);
    when(() => espJpn.getWordStatusAfter(any(), any()))
        .thenAnswer((_) async => []);
    when(() => jpnEsp.getWordStatusAfter(any(), any()))
        .thenAnswer((_) async => []);
    when(() => outbox.enqueue(any())).thenAnswer((_) async {
      fence.remove('account-a');
    });
    await userProfile
        .upsertProfileFields(guestAccountScope, {'username': 'Guest name'});

    final useCase = MigrateGuestDataUseCase(
      database: database,
      wordStatus: DriftWordStatusGuestMigration(
        espJpn: espJpn,
        jpnEsp: jpnEsp,
        outboxWriter: outbox,
      ),
      myWord: MyWordGuestMigrationAdapter(myWord, myWordStatus, outbox),
      userProfile: userProfilePort,
      outboxWriter: outbox,
      sessionFence: fence,
    );

    await expectLater(
      useCase.execute('account-a', 1),
      throwsA(isA<GuestMigrationSessionChanged>()),
    );

    expect(await userProfile.getUsername(guestAccountScope), 'Guest name');
    expect(await userProfile.getProfile('account-a'), isNull);
  });

  test(
      'merges both WordStatus directions and queues direction-specific patches',
      () async {
    final espJpn = _EspJpnStatus();
    final jpnEsp = _JpnEspStatus();
    final outbox = _OutboxWriter();
    const guestEsp = EspJpnWordStatusTableData(
      wordId: 7,
      isLearned: 1,
      isBookmarked: 0,
      hasNote: 1,
      editAt: '2026-08-06T00:00:00.000Z',
      accountId: guestAccountScope,
      localRevision: 2,
      remoteRevision: null,
      deletedAt: null,
      lastMutationId: null,
    );
    const accountEsp = EspJpnWordStatusTableData(
      wordId: 7,
      isLearned: 0,
      isBookmarked: 1,
      hasNote: 0,
      editAt: '2026-08-06T00:00:00.000Z',
      accountId: 'account-a',
      localRevision: 3,
      remoteRevision: null,
      deletedAt: null,
      lastMutationId: null,
    );
    const guestJpn = JpnEspWordStatusTableData(
      wordId: 9,
      isLearned: 0,
      isBookmarked: 1,
      hasNote: 0,
      editAt: '2026-08-06T00:00:00.000Z',
      accountId: guestAccountScope,
      localRevision: 1,
      remoteRevision: null,
      deletedAt: null,
      lastMutationId: null,
    );
    const updatedJpn = JpnEspWordStatusTableData(
      wordId: 9,
      isLearned: 0,
      isBookmarked: 1,
      hasNote: 0,
      editAt: '2026-08-07T00:00:00.000Z',
      accountId: 'account-a',
      localRevision: 5,
      remoteRevision: null,
      deletedAt: null,
      lastMutationId: null,
    );
    when(() => espJpn.getWordStatusAfter(any(), guestAccountScope))
        .thenAnswer((_) async => [guestEsp]);
    when(() => espJpn.getWordStatusById(7, 'account-a'))
        .thenAnswer((_) async => accountEsp);
    when(() => espJpn.updateWordStatus(7, true, true, true, any(), 'account-a'))
        .thenAnswer((_) async => accountEsp);
    when(() => espJpn.deleteRow(7, guestAccountScope)).thenAnswer((_) async {});
    when(() => jpnEsp.getWordStatusAfter(any(), guestAccountScope))
        .thenAnswer((_) async => [guestJpn]);
    when(() => jpnEsp.getWordStatusById(9, 'account-a'))
        .thenAnswer((_) async => null);
    when(() =>
            jpnEsp.updateWordStatus(9, false, true, false, any(), 'account-a'))
        .thenAnswer((_) async => updatedJpn);
    when(() => jpnEsp.deleteRow(9, guestAccountScope)).thenAnswer((_) async {});
    when(() => outbox.enqueue(any())).thenAnswer((_) async {});

    await DriftWordStatusGuestMigration(
      espJpn: espJpn,
      jpnEsp: jpnEsp,
      outboxWriter: outbox,
    ).migrateGuestRows(
      accountId: 'account-a',
      migrationId: 'migration-1',
      clock: () => DateTime.utc(2026, 8, 7),
    );

    verify(() => espJpn.deleteRow(7, guestAccountScope)).called(1);
    verify(() => jpnEsp.deleteRow(9, guestAccountScope)).called(1);
    final mutations = verify(() => outbox.enqueue(captureAny()))
        .captured
        .cast<SyncMutation>();
    expect(mutations.map((mutation) => mutation.dataset), [
      SyncDataset.espJpnWordStatus,
      SyncDataset.jpnEspWordStatus,
    ]);
    expect(mutations.first.payload, {
      'isLearned': true,
      'isBookmarked': true,
      'hasNote': true,
    });
    expect(mutations.first.mutationId, 'migration-1:esp_jpn_word_status:7');
    expect(mutations.last.mutationId, 'migration-1:jpn_esp_word_status:9');
  });
}
