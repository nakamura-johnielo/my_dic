import 'dart:io';

import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:my_dic/core/infrastructure/database/drift/database_provider.dart';
import 'package:sqlite3/sqlite3.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('v1-v7 migration compatibility', () {
    for (final version in [1, 2, 3, 4, 5]) {
      final label = version == 2 || version == 3 ? ' (v1 schema alias)' : '';
      test('upgrades v$version$label and retains a sentinel row', () async {
        final fixture = await _UserFixture.create(version);
        final database =
            DatabaseProvider.forTesting(NativeDatabase(fixture.file));
        try {
          final row = await database.customSelect('''
            SELECT my_word_id, account_id, local_revision, deleted_at
            FROM my_words WHERE my_word_id = '42'
          ''').getSingle();
          final status = await database.customSelect('''
            SELECT my_word_id, account_id, is_learned
            FROM my_word_status WHERE my_word_id = '42'
          ''').getSingle();
          final versionNow =
              await database.customSelect('PRAGMA user_version').getSingle();

          expect(row.data, {
            'my_word_id': '42',
            'account_id': 'legacy_unowned',
            'local_revision': 0,
            'deleted_at': null,
          });
          expect(status.data, {
            'my_word_id': '42',
            'account_id': 'legacy_unowned',
            'is_learned': 1,
          });
          expect(versionNow.data['user_version'], 7);
        } finally {
          await database.close();
          await fixture.dispose();
        }
      });
    }

    test('upgrades v6 outbox cursor/attempt/lease and sets client update time',
        () async {
      final fixture = await _OutboxV6Fixture.create();
      final database =
          DatabaseProvider.forTesting(NativeDatabase(fixture.file));
      try {
        final row = await database.customSelect('''
          SELECT mutation_id, attempt_count, next_attempt_at, lease_token,
                 lease_until, created_at, client_updated_at
          FROM sync_outbox WHERE mutation_id = 'legacy-mutation'
        ''').getSingle();
        expect(row.data['attempt_count'], 2);
        expect(row.data['next_attempt_at'], 1000);
        expect(row.data['lease_token'], 'lease');
        expect(row.data['lease_until'], 2000);
        expect(row.data['client_updated_at'], row.data['created_at']);
      } finally {
        await database.close();
        await fixture.dispose();
      }
    });

    test('reopens a v7 database without changing its sentinel row', () async {
      final fixture = await _UserFixture.create(5);
      final first = DatabaseProvider.forTesting(NativeDatabase(fixture.file));
      await first.customSelect('SELECT 1 FROM my_words').get();
      await first.close();

      final reopened =
          DatabaseProvider.forTesting(NativeDatabase(fixture.file));
      try {
        final row = await reopened.customSelect('''
          SELECT my_word_id, account_id FROM my_words WHERE my_word_id = '42'
        ''').getSingle();
        expect(row.data, {'my_word_id': '42', 'account_id': 'legacy_unowned'});
      } finally {
        await reopened.close();
        await fixture.dispose();
      }
    });
  });
}

final class _UserFixture {
  _UserFixture(this.directory, this.file);
  final Directory directory;
  final File file;

  static Future<_UserFixture> create(int version) async {
    final directory =
        await Directory.systemTemp.createTemp('db_contract_v$version');
    final file =
        File('${directory.path}${Platform.pathSeparator}legacy.sqlite');
    final raw = sqlite3.open(file.path);
    try {
      final idType = version >= 5 ? 'TEXT' : 'INTEGER';
      raw.execute('''
        CREATE TABLE my_words (
          my_word_id $idType PRIMARY KEY, word TEXT NOT NULL, contents TEXT,
          edit_at TEXT NOT NULL
        );
        CREATE TABLE my_word_status (
          my_word_id $idType PRIMARY KEY, is_learned INTEGER,
          is_bookmarked INTEGER, has_note INTEGER, edit_at TEXT NOT NULL
        );
        INSERT INTO my_words VALUES (42, 'hola', 'meaning', '2026-01-01T00:00:00Z');
        INSERT INTO my_word_status VALUES (42, 1, 0, 1, '2026-01-01T00:00:00Z');
        PRAGMA user_version = $version;
      ''');
    } finally {
      raw.dispose();
    }
    return _UserFixture(directory, file);
  }

  Future<void> dispose() => directory.delete(recursive: true);
}

final class _OutboxV6Fixture {
  _OutboxV6Fixture(this.directory, this.file);
  final Directory directory;
  final File file;

  static Future<_OutboxV6Fixture> create() async {
    final directory = await Directory.systemTemp.createTemp('db_contract_v6');
    final file =
        File('${directory.path}${Platform.pathSeparator}legacy.sqlite');
    final raw = sqlite3.open(file.path);
    try {
      raw.execute('''
        CREATE TABLE sync_outbox (
          mutation_id TEXT NOT NULL PRIMARY KEY, account_id TEXT NOT NULL,
          dataset TEXT NOT NULL, entity_id TEXT NOT NULL, operation TEXT NOT NULL,
          payload TEXT NOT NULL, field_mask TEXT NOT NULL, payload_version INTEGER NOT NULL,
          local_revision INTEGER NOT NULL, base_remote_revision TEXT, state TEXT NOT NULL,
          attempt_count INTEGER NOT NULL, next_attempt_at INTEGER NOT NULL,
          lease_token TEXT, lease_until INTEGER, created_at INTEGER NOT NULL,
          last_error_code TEXT
        );
        INSERT INTO sync_outbox VALUES (
          'legacy-mutation', 'account', 'my_words', '42', 'patch', '{}', '[]',
          1, 1, NULL, 'pending', 2, 1000, 'lease', 2000, 900, NULL
        );
        PRAGMA user_version = 6;
      ''');
    } finally {
      raw.dispose();
    }
    return _OutboxV6Fixture(directory, file);
  }

  Future<void> dispose() => directory.delete(recursive: true);
}
