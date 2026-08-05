import 'dart:io';

import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:my_dic/core/infrastructure/database/drift/database_provider.dart';
import 'package:sqlite3/sqlite3.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('DatabaseProvider legacy migrations', () {
    for (final version in [1, 2, 3, 4]) {
      test('migrates v$version MyWord relations and values to v5', () async {
        final fixture = await _LegacyFixture.create(version: version);
        final database = DatabaseProvider.forTesting(
          NativeDatabase(fixture.file),
        );

        try {
          final words = await database.customSelect('''
            SELECT my_word_id, word, contents, edit_at
            FROM my_words
            ORDER BY CAST(my_word_id AS INTEGER)
          ''').get();
          final statuses = await database.customSelect('''
            SELECT my_word_id, is_learned, is_bookmarked, has_note, edit_at
            FROM my_word_status
            ORDER BY CAST(my_word_id AS INTEGER)
          ''').get();
          final idColumn = await database.customSelect('''
            SELECT type FROM pragma_table_info('my_words')
            WHERE name = 'my_word_id'
          ''').getSingle();
          final userVersion =
              await database.customSelect('PRAGMA user_version;').getSingle();

          expect(idColumn.data['type'], 'TEXT');
          expect(userVersion.data['user_version'], 5);
          expect(
            words.map((row) => row.data).toList(),
            [
              {
                'my_word_id': '10',
                'word': 'hola',
                'contents': 'こんにちは',
                'edit_at': '2026-01-01T00:00:00.000Z',
              },
              {
                'my_word_id': '20',
                'word': 'adios',
                'contents': null,
                'edit_at': '2026-01-02T00:00:00.000Z',
              },
              {
                'my_word_id': '30',
                'word': 'libro',
                'contents': '本',
                'edit_at': '2026-01-03T00:00:00.000Z',
              },
            ],
          );
          expect(
            statuses.map((row) => row.data).toList(),
            [
              {
                'my_word_id': '10',
                'is_learned': 1,
                'is_bookmarked': 0,
                'has_note': 1,
                'edit_at': '2026-01-04T00:00:00.000Z',
              },
              {
                'my_word_id': '30',
                'is_learned': null,
                'is_bookmarked': 1,
                'has_note': null,
                'edit_at': '2026-01-05T00:00:00.000Z',
              },
            ],
          );
        } finally {
          await database.close();
          await fixture.dispose();
        }
      });
    }

    test('rolls back v5 migration when a status has no MyWord', () async {
      final fixture = await _LegacyFixture.create(
        version: 4,
        includeOrphanStatus: true,
      );
      final database =
          DatabaseProvider.forTesting(NativeDatabase(fixture.file));

      await expectLater(
        database.customSelect('SELECT 1;').get(),
        throwsA(isA<StateError>()),
      );
      await database.close();

      final legacy = sqlite3.open(fixture.file.path);
      try {
        expect(legacy.userVersion, 4);
        expect(
          legacy
              .select(
                "SELECT name FROM sqlite_master WHERE type = 'table' AND name IN ('my_words', 'my_word_status') ORDER BY name;",
              )
              .map((row) => row['name'])
              .toList(),
          ['my_word_status', 'my_words'],
        );
        expect(
          legacy.select(
            "SELECT name FROM sqlite_master WHERE type = 'table' AND name LIKE '%_old';",
          ),
          isEmpty,
        );
        expect(
          legacy
              .select('SELECT COUNT(*) AS count FROM my_words;')
              .single['count'],
          3,
        );
        expect(
          legacy
              .select('SELECT COUNT(*) AS count FROM my_word_status;')
              .single['count'],
          3,
        );
      } finally {
        legacy.dispose();
        await fixture.dispose();
      }
    });
  });
}

class _LegacyFixture {
  _LegacyFixture._(this.directory, this.file);

  final Directory directory;
  final File file;

  static Future<_LegacyFixture> create({
    required int version,
    bool includeOrphanStatus = false,
  }) async {
    final directory = await Directory.systemTemp.createTemp('my_dic_v$version');
    final file = File(
      '${directory.path}${Platform.pathSeparator}fixture.sqlite',
    );
    final legacy = sqlite3.open(file.path);
    try {
      legacy.execute('''
        CREATE TABLE my_words (
          my_word_id INTEGER PRIMARY KEY,
          word TEXT NOT NULL,
          contents TEXT,
          edit_at TEXT NOT NULL
        );
        CREATE TABLE my_word_status (
          my_word_id INTEGER PRIMARY KEY,
          is_learned INTEGER,
          is_bookmarked INTEGER,
          has_note INTEGER,
          edit_at TEXT NOT NULL
        );
        INSERT INTO my_words VALUES
          (10, 'hola', 'こんにちは', '2026-01-01T00:00:00.000Z'),
          (20, 'adios', NULL, '2026-01-02T00:00:00.000Z'),
          (30, 'libro', '本', '2026-01-03T00:00:00.000Z');
        INSERT INTO my_word_status VALUES
          (10, 1, 0, 1, '2026-01-04T00:00:00.000Z'),
          (30, NULL, 1, NULL, '2026-01-05T00:00:00.000Z');
        PRAGMA user_version = $version;
      ''');
      if (includeOrphanStatus) {
        legacy.execute('''
          INSERT INTO my_word_status VALUES
            (999, 1, 1, 1, '2026-01-06T00:00:00.000Z');
        ''');
      }
    } finally {
      legacy.dispose();
    }
    return _LegacyFixture._(directory, file);
  }

  Future<void> dispose() => directory.delete(recursive: true);
}
