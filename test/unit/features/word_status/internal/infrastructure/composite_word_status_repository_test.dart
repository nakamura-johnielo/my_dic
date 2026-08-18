import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:my_dic/core/infrastructure/database/drift/database_provider.dart';
import 'package:my_dic/core/shared/consts/account_scope.dart';
import 'package:my_dic/features/sync/port/sync_dataset.dart';
import 'package:my_dic/core/shared/errors/infrastructure_errors.dart';
import 'package:my_dic/features/sync/port/outbox_writer.dart';
import 'package:my_dic/features/sync/internal/infrastructure/persistence/drift/drift_outbox_writer.dart';
import 'package:my_dic/features/word_status/port/word_status.dart';
import 'package:my_dic/features/word_status/internal/infrastructure/esp_jpn/esp_jpn_dictionary_word_status_store.dart';
import 'package:my_dic/features/word_status/internal/infrastructure/esp_jpn/drift/esp_jpn_word_status_dao.dart';
import 'package:my_dic/features/word_status/internal/infrastructure/esp_jpn/drift/esp_jpn_word_status_local_data_source.dart';
import 'package:my_dic/features/word_status/internal/infrastructure/esp_jpn/drift/esp_jpn_word_status_local_store.dart';
import 'package:my_dic/features/word_status/internal/infrastructure/jpn_esp/jpn_esp_dictionary_word_status_store.dart';
import 'package:my_dic/features/word_status/internal/infrastructure/jpn_esp/drift/jpn_esp_word_status_dao.dart';
import 'package:my_dic/features/word_status/internal/infrastructure/jpn_esp/drift/jpn_esp_word_status_local_store.dart';
import 'package:my_dic/features/word_status/internal/infrastructure/composite_word_status_repository.dart';

class _Adapter extends Mock implements DictionaryWordStatusStore {}

class _EspJpnLocal extends Mock implements EspJpnWordStatusLocalDataSource {}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('CompositeWordStatusRepository registry', () {
    test('rejects duplicate CatalogId registrations', () {
      final first = _Adapter();
      final second = _Adapter();
      when(() => first.catalogId).thenReturn(CatalogId.espJpnMain);
      when(() => second.catalogId).thenReturn(CatalogId.espJpnMain);

      expect(
        () => CompositeWordStatusRepository([first, second]),
        throwsArgumentError,
      );
    });

    test('supports an explicit subset without depending on CatalogId.values', () {
      final onlyAdapter = _Adapter();
      when(() => onlyAdapter.catalogId).thenReturn(CatalogId.espJpnMain);

      final repository = CompositeWordStatusRepository([onlyAdapter]);
      expect(repository.supportedCatalogs, {CatalogId.espJpnMain});
    });
  });

  group('dictionary status adapters', () {
    late DatabaseProvider database;
    late CompositeWordStatusRepository repository;

    setUp(() {
      database = DatabaseProvider.forTesting(NativeDatabase.memory());
      final outbox = DriftOutboxWriter(database);
      repository = CompositeWordStatusRepository([
        EspJpnDictionaryWordStatusStore(
          EspJpnWordStatusLocalStore(EspJpnWordStatusDao(database)),
          outbox,
        ),
        JpnEspDictionaryWordStatusStore(
          JpnEspWordStatusLocalStore(JpnEspWordStatusDao(database)),
          outbox,
        ),
      ]);
    });

    tearDown(() => database.close());

    test('dispatches by catalog and keeps account-scoped rows isolated',
        () async {
      const esp = CatalogWordRef(catalogId: CatalogId.espJpnMain, wordId: 1);
      const jpn = CatalogWordRef(catalogId: CatalogId.jpnEspMain, wordId: 1);
      final time = DateTime(2026, 8, 9, 9, 30);

      await repository.update(esp,
          isLearned: const FieldUpdate.set(true),
          isBookmarked: const FieldUpdate.set(false),
          hasNote: const FieldUpdate.set(true),
          updatedAt: time,
          accountId: 'account-a');
      await repository.update(jpn,
          isLearned: const FieldUpdate.set(false),
          isBookmarked: const FieldUpdate.set(true),
          hasNote: const FieldUpdate.set(false),
          updatedAt: time,
          accountId: 'account-a');

      final espStatus =
          (await repository.get(esp, accountId: 'account-a')).dataOrNull!;
      final jpnStatus =
          (await repository.get(jpn, accountId: 'account-a')).dataOrNull!;
      expect(espStatus.isLearned, isTrue);
      expect(espStatus.hasNote, isTrue);
      expect(jpnStatus.isBookmarked, isTrue);
      expect(jpnStatus.isLearned, isFalse);
      expect((await repository.get(esp, accountId: 'account-b')).dataOrNull,
          isNull);

      final outboxRows = await database.select(database.syncOutbox).get();
      expect(
          outboxRows.map((row) => row.dataset),
          containsAll([
            SyncDataset.espJpnWordStatus.stableId,
            SyncDataset.jpnEspWordStatus.stableId
          ]));
      expect(
        outboxRows.map((row) => row.clientUpdatedAt.toUtc()),
        everyElement(time.toUtc()),
      );
    });

    test('watch emits a false default for a missing row', () async {
      const word = CatalogWordRef(
        catalogId: CatalogId.espJpnMain,
        wordId: 99,
      );

      final status =
          await repository.watch(word, accountId: guestAccountScope).first;

      expect(status.word, word);
      expect(status.isLearned, isFalse);
      expect(status.isBookmarked, isFalse);
      expect(status.hasNote, isFalse);
      expect(status.updatedAt, isNull);
    });
  });

  test('preserves the identity of an AppError from a local datasource',
      () async {
    final local = _EspJpnLocal();
    final expected = DatabaseError(message: 'typed failure');
    when(() => local.getWordStatusRecordById(1, 'account-a'))
        .thenThrow(expected);
    final adapter = EspJpnDictionaryWordStatusStore(local, _OutboxWriter());

    final result = await adapter.get(
      const CatalogWordRef(catalogId: CatalogId.espJpnMain, wordId: 1),
      accountId: 'account-a',
    );

    expect(result, isA<Failure<WordStatus?>>());
    expect(result.errorOrNull, same(expected));
  });
}

class _OutboxWriter extends Mock implements OutboxWriter {}
