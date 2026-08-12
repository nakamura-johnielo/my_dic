import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:my_dic/core/infrastructure/database/drift/database_provider.dart';
import 'package:my_dic/core/shared/consts/account_scope.dart';
import 'package:my_dic/features/sync/port/sync_dataset.dart';
import 'package:my_dic/core/shared/errors/infrastructure_errors.dart';
import 'package:my_dic/core/shared/utils/result.dart';
import 'package:my_dic/core/shared/value_objects/field_update.dart';
import 'package:my_dic/features/catalog/port/catalog.dart';
import 'package:my_dic/features/sync/port/outbox_writer.dart';
import 'package:my_dic/features/sync/internal/infrastructure/persistence/drift/drift_outbox_writer.dart';
import 'package:my_dic/features/word_status/port/word_status.dart';
import 'package:my_dic/features/word_status/internal/infrastructure/esp_jpn/esp_jpn_dictionary_word_status_adapter.dart';
import 'package:my_dic/features/word_status/internal/infrastructure/esp_jpn/drift/esp_jpn_word_status_dao.dart';
import 'package:my_dic/features/word_status/internal/infrastructure/esp_jpn/drift/esp_jpn_word_status_local_data_source.dart';
import 'package:my_dic/features/word_status/internal/infrastructure/esp_jpn/drift/esp_jpn_word_status_local_store.dart';
import 'package:my_dic/features/word_status/internal/infrastructure/jpn_esp/jpn_esp_dictionary_word_status_adapter.dart';
import 'package:my_dic/features/word_status/internal/infrastructure/jpn_esp/drift/jpn_esp_word_status_dao.dart';
import 'package:my_dic/features/word_status/internal/infrastructure/jpn_esp/drift/jpn_esp_word_status_local_store.dart';
import 'package:my_dic/features/word_status/internal/infrastructure/word_status_repository_adapter.dart';

class _Adapter extends Mock implements DictionaryWordStatusAdapter {}

class _EspJpnLocal extends Mock implements EspJpnWordStatusLocalDataSource {}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('WordStatusRepositoryAdapter registry', () {
    test('rejects duplicate CatalogId registrations', () {
      final first = _Adapter();
      final second = _Adapter();
      when(() => first.catalogId).thenReturn(CatalogId.espJpnMain);
      when(() => second.catalogId).thenReturn(CatalogId.espJpnMain);

      expect(
        () => WordStatusRepositoryAdapter([first, second]),
        throwsArgumentError,
      );
    });

    test('rejects a registry that does not cover every CatalogId', () {
      final onlyAdapter = _Adapter();
      when(() => onlyAdapter.catalogId).thenReturn(CatalogId.espJpnMain);

      expect(
        () => WordStatusRepositoryAdapter([onlyAdapter]),
        throwsArgumentError,
      );
    });
  });

  group('dictionary status adapters', () {
    late DatabaseProvider database;
    late WordStatusRepositoryAdapter repository;

    setUp(() {
      database = DatabaseProvider.forTesting(NativeDatabase.memory());
      final outbox = DriftOutboxWriter(database);
      repository = WordStatusRepositoryAdapter([
        EspJpnDictionaryWordStatusAdapter(
          EspJpnWordStatusLocalStore(EspJpnWordStatusDao(database)),
          outbox,
        ),
        JpnEspDictionaryWordStatusAdapter(
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
      expect(status.updatedAt,
          DateTime.fromMillisecondsSinceEpoch(0, isUtc: true));
    });
  });

  test('preserves the identity of an AppError from a local datasource',
      () async {
    final local = _EspJpnLocal();
    final expected = DatabaseError(message: 'typed failure');
    when(() => local.getWordStatusById(1, 'account-a')).thenThrow(expected);
    final adapter = EspJpnDictionaryWordStatusAdapter(local, _OutboxWriter());

    final result = await adapter.get(
      const CatalogWordRef(catalogId: CatalogId.espJpnMain, wordId: 1),
      accountId: 'account-a',
    );

    expect(result, isA<Failure<WordStatus?>>());
    expect(result.errorOrNull, same(expected));
  });
}

class _OutboxWriter extends Mock implements OutboxWriter {}
