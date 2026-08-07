import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:my_dic/core/infrastructure/database/drift/daos/esp_jpn/esp_jpn_word_status_dao.dart';
import 'package:my_dic/core/infrastructure/database/drift/daos/jpn_esp/jpn_esp_word_status_dao.dart';
import 'package:my_dic/core/infrastructure/database/drift/database_provider.dart';
import 'package:my_dic/core/infrastructure/datasource/jpn_esp_word_status/jpn_esp_drift_word_status_data_source.dart';
import 'package:my_dic/core/infrastructure/datasource/word_status/drift_word_status_data_source.dart';
import 'package:my_dic/core/shared/consts/account_scope.dart';
import 'package:my_dic/core/shared/enums/sync_dataset.dart';
import 'package:my_dic/core/shared/utils/result.dart';
import 'package:my_dic/core/shared/value_objects/field_update.dart';
import 'package:my_dic/features/esp_jpn_word_status/data/wordstatus_repository.dart';
import 'package:my_dic/features/esp_jpn_word_status/domain/esp_word_status.dart';
import 'package:my_dic/features/esp_jpn_word_status/domain/i_word_status_repository.dart';
import 'package:my_dic/features/esp_jpn_word_status/application/fetch_esp_jpn_word_status_usecase.dart';
import 'package:my_dic/features/esp_jpn_word_status/application/watch_esp_jpn_word_status_usecase.dart';
import 'package:my_dic/features/jpn_esp_word_status/data/jpn_esp_word_status_repository.dart';
import 'package:my_dic/features/jpn_esp_word_status/domain/i_jpn_esp_word_status_repository.dart';
import 'package:my_dic/features/jpn_esp_word_status/domain/jpn_esp_word_status.dart';
import 'package:my_dic/features/jpn_esp_word_status/application/watch_jpn_esp_word_status_usecase.dart';
import 'package:my_dic/features/sync/application/model/sync_mutation.dart';
import 'package:my_dic/features/sync/application/port/outbox_writer.dart';

import '../../../helpers/fake_current_session.dart';

class _MockOutboxWriter extends Mock implements OutboxWriter {}

class _MockEspJpnRepository extends Mock implements IWordStatusRepository {}

class _MockJpnEspRepository extends Mock
    implements IJpnEspWordStatusRepository {}

abstract interface class _ScopeFixture {
  Future<void> apply(String? accountId,
      {required bool isLearned, required bool isBookmarked});
  Future<({bool? learned, bool? bookmarked})?> readAs(String accountId);
  Future<void> close();
}

class _EspJpnScopeFixture implements _ScopeFixture {
  _EspJpnScopeFixture._(this._database, this._repository);

  final DatabaseProvider _database;
  final WordStatusRepository _repository;

  static Future<_EspJpnScopeFixture> create() async {
    final database = DatabaseProvider.forTesting(NativeDatabase.memory());
    final local = DriftWordStatusDataSource(EspJpnWordStatusDao(database));
    final writer = _MockOutboxWriter();
    when(() => writer.enqueue(any())).thenAnswer((_) async {});
    return _EspJpnScopeFixture._(
      database,
      WordStatusRepository(local, writer),
    );
  }

  @override
  Future<void> apply(String? accountId,
      {required bool isLearned, required bool isBookmarked}) async {
    final result = await _repository.updateLocalWordStatus(
      wordId: 1,
      isLearned: FieldUpdate.set(isLearned),
      isBookmarked: FieldUpdate.set(isBookmarked),
      hasNote: const FieldUpdate.unchanged(),
      editAt: DateTime.utc(2026, 8, 6),
      accountId: accountId,
    );
    expect(result.isSuccess, isTrue);
  }

  @override
  Future<({bool? learned, bool? bookmarked})?> readAs(String accountId) async {
    final result = await _repository.getWordStatusById(1, accountId: accountId);
    expect(result.isSuccess, isTrue);
    final data = result.dataOrNull;
    if (data == null) return null;
    return (learned: data.isLearned, bookmarked: data.isBookmarked);
  }

  @override
  Future<void> close() => _database.close();
}

class _JpnEspScopeFixture implements _ScopeFixture {
  _JpnEspScopeFixture._(this._database, this._repository);

  final DatabaseProvider _database;
  final JpnEspWordStatusRepository _repository;

  static Future<_JpnEspScopeFixture> create() async {
    final database = DatabaseProvider.forTesting(NativeDatabase.memory());
    final local =
        JpnEspDriftWordStatusDataSource(JpnEspWordStatusDao(database));
    final writer = _MockOutboxWriter();
    when(() => writer.enqueue(any())).thenAnswer((_) async {});
    return _JpnEspScopeFixture._(
      database,
      JpnEspWordStatusRepository(local, writer),
    );
  }

  @override
  Future<void> apply(String? accountId,
      {required bool isLearned, required bool isBookmarked}) async {
    final result = await _repository.updateLocalWordStatus(
      wordId: 1,
      isLearned: FieldUpdate.set(isLearned),
      isBookmarked: FieldUpdate.set(isBookmarked),
      hasNote: const FieldUpdate.unchanged(),
      editAt: DateTime.utc(2026, 8, 6),
      accountId: accountId,
    );
    expect(result.isSuccess, isTrue);
  }

  @override
  Future<({bool? learned, bool? bookmarked})?> readAs(String accountId) async {
    final result = await _repository.getWordStatusById(1, accountId: accountId);
    expect(result.isSuccess, isTrue);
    final data = result.dataOrNull;
    if (data == null) return null;
    return (learned: data.isLearned, bookmarked: data.isBookmarked);
  }

  @override
  Future<void> close() => _database.close();
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(() {
    registerFallbackValue(SyncMutation(
      mutationId: 'fallback',
      accountId: 'fallback',
      dataset: SyncDataset.espJpnWordStatus,
      entityId: '0',
      operation: SyncMutationOperation.patch,
      payload: const {},
      fieldMask: const [],
      localRevision: 0,
      clientUpdatedAt: DateTime.utc(2026),
    ));
  });

  final fixtures = <String, Future<_ScopeFixture> Function()>{
    'Esp-Jpn': _EspJpnScopeFixture.create,
    'Jpn-Esp': _JpnEspScopeFixture.create,
  };

  for (final fixtureEntry in fixtures.entries) {
    group('${fixtureEntry.key} local row account scoping', () {
      late _ScopeFixture fixture;

      setUp(() async {
        fixture = await fixtureEntry.value();
      });

      tearDown(() => fixture.close());

      test(
          'two signed-in accounts on the same wordId do not see or '
          'overwrite each other', () async {
        await fixture.apply('account-a', isLearned: true, isBookmarked: false);
        await fixture.apply('account-b', isLearned: false, isBookmarked: true);

        final a = await fixture.readAs('account-a');
        final b = await fixture.readAs('account-b');

        expect(a, (learned: true, bookmarked: false));
        expect(b, (learned: false, bookmarked: true));
      });

      test('guest writes are isolated from a signed-in account scope',
          () async {
        await fixture.apply(null, isLearned: true, isBookmarked: true);

        final asAccount = await fixture.readAs('account-a');
        final asGuest = await fixture.readAs(guestAccountScope);

        expect(asAccount, isNull);
        expect(asGuest, (learned: true, bookmarked: true));
      });
    });
  }

  group('Fetch/Watch interactors resolve accountId from CurrentSession', () {
    test('Esp-Jpn fetch/watch use the guest scope when signed out', () async {
      final repository = _MockEspJpnRepository();
      when(() => repository.getWordStatusById(1,
              accountId: any(named: 'accountId')))
          .thenAnswer((_) async => Result.success(WordStatus(wordId: 1)));
      when(() => repository.watchWordStatusById(1,
              accountId: any(named: 'accountId')))
          .thenAnswer((_) => Stream.value(WordStatus(wordId: 1)));

      final interactorUnderFetch =
          FetchEspJpnWordStatusInteractor(repository, FakeCurrentSession());
      await interactorUnderFetch.execute(1);
      interactorUnderFetch.watch(1);

      verify(() =>
              repository.getWordStatusById(1, accountId: guestAccountScope))
          .called(1);
      verify(() =>
              repository.watchWordStatusById(1, accountId: guestAccountScope))
          .called(1);

      final watchInteractor =
          WatchEspJpnWordStatusInteractor(repository, FakeCurrentSession());
      watchInteractor.execute(1);
      verify(() =>
              repository.watchWordStatusById(1, accountId: guestAccountScope))
          .called(1);
    });

    test('Esp-Jpn fetch/watch use the real accountId when signed in', () async {
      final repository = _MockEspJpnRepository();
      when(() => repository.getWordStatusById(1,
              accountId: any(named: 'accountId')))
          .thenAnswer((_) async => Result.success(WordStatus(wordId: 1)));
      when(() => repository.watchWordStatusById(1,
              accountId: any(named: 'accountId')))
          .thenAnswer((_) => Stream.value(WordStatus(wordId: 1)));

      final session = FakeCurrentSession(accountIdOrNull: 'account-a');
      final fetchInteractor =
          FetchEspJpnWordStatusInteractor(repository, session);
      await fetchInteractor.execute(1);

      verify(() => repository.getWordStatusById(1, accountId: 'account-a'))
          .called(1);
    });

    test('Jpn-Esp watch uses CurrentSession accountId scope', () async {
      final repository = _MockJpnEspRepository();
      when(() => repository.watchWordStatusById(1,
              accountId: any(named: 'accountId')))
          .thenAnswer((_) => Stream.value(JpnEspWordStatus(wordId: 1)));

      final signedIn = WatchJpnEspWordStatusInteractor(
          repository, FakeCurrentSession(accountIdOrNull: 'account-c'));
      signedIn.execute(1);
      verify(() => repository.watchWordStatusById(1, accountId: 'account-c'))
          .called(1);

      final guest =
          WatchJpnEspWordStatusInteractor(repository, FakeCurrentSession());
      guest.execute(1);
      verify(() =>
              repository.watchWordStatusById(1, accountId: guestAccountScope))
          .called(1);
    });
  });
}
