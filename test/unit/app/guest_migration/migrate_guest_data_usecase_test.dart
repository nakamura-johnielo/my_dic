import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:my_dic/app/guest_migration/migrate_guest_data_usecase.dart';
import 'package:my_dic/core/infrastructure/database/drift/database_provider.dart';
import 'package:my_dic/core/infrastructure/datasource/jpn_esp_word_status/i_local_jpn_esp_word_status_data_source.dart';
import 'package:my_dic/core/infrastructure/datasource/word_status/i_local_word_status_data_source.dart';
import 'package:my_dic/core/shared/consts/account_scope.dart';
import 'package:my_dic/core/shared/enums/sync_dataset.dart';
import 'package:my_dic/features/my_word/data/data_source/local/drift_my_word_dao.dart';
import 'package:my_dic/features/my_word/data/data_source/local/drift_my_word_status_dao.dart';
import 'package:my_dic/features/my_word/data/data_source/local/my_word_drift_data_source.dart';
import 'package:my_dic/features/my_word/data/data_source/local/my_word_status_drift_data_source.dart';
import 'package:my_dic/features/sync/application/model/sync_mutation.dart';
import 'package:my_dic/features/sync/application/in_memory_session_fence.dart';
import 'package:my_dic/features/sync/application/port/outbox_writer.dart';
import 'package:my_dic/features/user/data/data_source/local/drift_user_profile_dao.dart';
import 'package:my_dic/features/user/data/data_source/local/user_profile_drift_data_source.dart';

class _EspJpnStatus extends Mock implements ILocalWordStatusDataSource {}

class _JpnEspStatus extends Mock implements ILocalJpnEspWordStatusDataSource {}

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
      espJpnWordStatus: espJpn,
      jpnEspWordStatus: jpnEsp,
      myWord: myWord,
      myWordStatus: myWordStatus,
      userProfile: userProfile,
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

  test('imports a guest profile only when the account has no username',
      () async {
    final database = DatabaseProvider.forTesting(NativeDatabase.memory());
    addTearDown(database.close);
    final myWord = MyWordDriftDataSource(MyWordDao(database));
    final myWordStatus = MyWordStatusDriftDataSource(MyWordStatusDao(database));
    final userProfile = UserProfileDriftDataSource(UserProfileDao(database));
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
      espJpnWordStatus: espJpn,
      jpnEspWordStatus: jpnEsp,
      myWord: myWord,
      myWordStatus: myWordStatus,
      userProfile: userProfile,
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
      espJpnWordStatus: espJpn,
      jpnEspWordStatus: jpnEsp,
      myWord: myWord,
      myWordStatus: myWordStatus,
      userProfile: userProfile,
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
}
