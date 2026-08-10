@TestOn('browser')
library;

import 'package:flutter_test/flutter_test.dart';
import 'package:my_dic/core/infrastructure/database/drift/database_provider.dart';
import '../../support/database/web_indexeddb.dart';
import '../../support/database/web_legacy_schema_creator.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('fresh IndexedDB seeds once and existing IndexedDB reopens unchanged',
      () async {
    await deleteMyDicIndexedDb();

    final fresh = DatabaseProvider();
    try {
      final words = await fresh
          .customSelect('SELECT COUNT(*) AS count FROM words;')
          .getSingle();
      expect(words.read<int>('count'), greaterThan(0));
      await fresh.customStatement(
        "INSERT INTO my_words "
        "(my_word_id, word, edit_at, account_id, local_revision) VALUES "
        "('web-reopen-sentinel', 'hola', '2026-01-01T00:00:00Z', "
        "'web-test', 0);",
      );
    } finally {
      await fresh.close();
    }

    final reopened = DatabaseProvider();
    try {
      final sentinel = await reopened
          .customSelect(
            "SELECT word FROM my_words WHERE account_id = 'web-test' "
            "AND my_word_id = 'web-reopen-sentinel';",
          )
          .getSingle();
      expect(sentinel.read<String>('word'), 'hola');
    } finally {
      await reopened.close();
      await deleteMyDicIndexedDb();
    }
  }, timeout: const Timeout(Duration(minutes: 15)));

  for (final version in List<int>.generate(7, (index) => index + 1)) {
    test('opens v$version legacy IndexedDB once without duplicating seed data',
        () async {
      await deleteMyDicIndexedDb();
      await createLegacyWebSchema(version);

      final migrated = DatabaseProvider();
      try {
        final userVersion =
            await migrated.customSelect('PRAGMA user_version;').getSingle();
        final legacyWord = await migrated
            .customSelect(
              "SELECT word FROM my_words WHERE account_id = 'legacy_unowned' "
              "AND my_word_id = 'legacy-$version';",
            )
            .getSingle();
        final conjugationCount = await migrated
            .customSelect('SELECT COUNT(*) AS count FROM es_en_conjugacions;')
            .getSingle();
        expect(userVersion.read<int>('user_version'), 7);
        expect(legacyWord.read<String>('word'), 'legacy-$version');
        expect(conjugationCount.read<int>('count'), 0,
            reason: 'the current Web upgrade path intentionally has no seed');
      } finally {
        await migrated.close();
      }

      final reopened = DatabaseProvider();
      try {
        final legacyWord = await reopened
            .customSelect(
              "SELECT word FROM my_words WHERE account_id = 'legacy_unowned' "
              "AND my_word_id = 'legacy-$version';",
            )
            .getSingle();
        final conjugationCount = await reopened
            .customSelect('SELECT COUNT(*) AS count FROM es_en_conjugacions;')
            .getSingle();
        expect(legacyWord.read<String>('word'), 'legacy-$version');
        expect(conjugationCount.read<int>('count'), 0);
      } finally {
        await reopened.close();
        await deleteMyDicIndexedDb();
      }
    }, timeout: const Timeout(Duration(minutes: 15)));
  }
}
