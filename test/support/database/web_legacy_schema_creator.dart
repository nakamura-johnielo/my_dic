import 'package:drift/drift.dart';
import 'package:drift/wasm.dart';

/// Creates the historical IndexedDB inputs without importing production table
/// declarations or [DatabaseProvider]. Versions 2 and 3 intentionally use the
/// v1 schema because this repository has no separate historical schema for
/// them; production migration treats them as that same input.
Future<void> createLegacyWebSchema(int version) async {
  final wasm = await WasmDatabase.open(
    databaseName: 'my_dic_db',
    sqlite3Uri: Uri.parse('sqlite3.wasm'),
    driftWorkerUri: Uri.parse('drift_worker.js'),
  );
  final database = _LegacySqlDatabase(wasm.resolvedExecutor);
  try {
    await _createSharedTables(database);
    await _createUserTables(database, version);
    if (version >= 6) await _createV6SyncOutbox(database, version);
    await database.customStatement('PRAGMA user_version = $version;');
  } finally {
    await database.close();
  }
}

Future<void> _createSharedTables(_LegacySqlDatabase database) async {
  await database.customStatement('''
    CREATE TABLE words (word_id INTEGER PRIMARY KEY, word TEXT NOT NULL);
    INSERT INTO words (word_id, word) VALUES (1, 'legacy-word');
    CREATE TABLE jpn_esp_words (
      jpn_esp_word_id INTEGER PRIMARY KEY, word TEXT NOT NULL
    );
    INSERT INTO jpn_esp_words (jpn_esp_word_id, word) VALUES (1, '旧語');
  ''');
}

Future<void> _createUserTables(
  _LegacySqlDatabase database,
  int version,
) async {
  if (version <= 4) {
    await database.customStatement('''
      CREATE TABLE my_words (
        my_word_id INTEGER PRIMARY KEY, word TEXT NOT NULL, contents TEXT,
        edit_at TEXT NOT NULL
      );
      INSERT INTO my_words VALUES
        (1, 'legacy-$version', 'meaning', '2026-01-01T00:00:00Z');
      CREATE TABLE my_word_status (
        my_word_id INTEGER PRIMARY KEY, is_learned INTEGER,
        is_bookmarked INTEGER, has_note INTEGER, edit_at TEXT NOT NULL
      );
      INSERT INTO my_word_status VALUES (1, 1, 0, 1, '2026-01-01T00:00:00Z');
      CREATE TABLE word_status (
        word_id INTEGER PRIMARY KEY, is_learned INTEGER, is_bookmarked INTEGER,
        has_note INTEGER, edit_at TEXT NOT NULL
      );
      INSERT INTO word_status VALUES (1, 1, 0, 0, '2026-01-01T00:00:00Z');
      CREATE TABLE jpn_esp_word_status (
        jpn_esp_word_id INTEGER PRIMARY KEY, is_learned INTEGER,
        is_bookmarked INTEGER, has_note INTEGER, edit_at TEXT NOT NULL
      );
      INSERT INTO jpn_esp_word_status VALUES
        (1, 0, 1, 0, '2026-01-01T00:00:00Z');
    ''');
    return;
  }

  final owned = version >= 6;
  final id = 'legacy-$version';
  await database.customStatement('''
    CREATE TABLE my_words (
      my_word_id TEXT NOT NULL, word TEXT NOT NULL, contents TEXT,
      edit_at TEXT NOT NULL${owned ? ', account_id TEXT NOT NULL, local_revision INTEGER NOT NULL DEFAULT 0, remote_revision TEXT, deleted_at INTEGER, last_mutation_id TEXT, PRIMARY KEY (account_id, my_word_id)' : ', PRIMARY KEY (my_word_id)'}
    );
    INSERT INTO my_words
      (my_word_id, word, contents, edit_at${owned ? ', account_id, local_revision' : ''})
      VALUES ('$id', '$id', 'meaning', '2026-01-01T00:00:00Z'${owned ? ", 'legacy_unowned', 0" : ''});
    CREATE TABLE my_word_status (
      my_word_id TEXT NOT NULL, is_learned INTEGER, is_bookmarked INTEGER,
      has_note INTEGER, edit_at TEXT NOT NULL${owned ? ', account_id TEXT NOT NULL, local_revision INTEGER NOT NULL DEFAULT 0, remote_revision TEXT, deleted_at INTEGER, last_mutation_id TEXT, PRIMARY KEY (account_id, my_word_id)' : ', PRIMARY KEY (my_word_id)'}
    );
    INSERT INTO my_word_status
      (my_word_id, is_learned, is_bookmarked, has_note, edit_at${owned ? ', account_id, local_revision' : ''})
      VALUES ('$id', 1, 0, 1, '2026-01-01T00:00:00Z'${owned ? ", 'legacy_unowned', 0" : ''});
    CREATE TABLE word_status (
      word_id INTEGER NOT NULL, is_learned INTEGER, is_bookmarked INTEGER,
      has_note INTEGER, edit_at TEXT NOT NULL${owned ? ', account_id TEXT NOT NULL, local_revision INTEGER NOT NULL DEFAULT 0, remote_revision TEXT, deleted_at INTEGER, last_mutation_id TEXT, PRIMARY KEY (account_id, word_id)' : ', PRIMARY KEY (word_id)'}
    );
    CREATE TABLE jpn_esp_word_status (
      jpn_esp_word_id INTEGER NOT NULL, is_learned INTEGER,
      is_bookmarked INTEGER, has_note INTEGER, edit_at TEXT NOT NULL${owned ? ', account_id TEXT NOT NULL, local_revision INTEGER NOT NULL DEFAULT 0, remote_revision TEXT, deleted_at INTEGER, last_mutation_id TEXT, PRIMARY KEY (account_id, jpn_esp_word_id)' : ', PRIMARY KEY (jpn_esp_word_id)'}
    );
  ''');
}

Future<void> _createV6SyncOutbox(
  _LegacySqlDatabase database,
  int version,
) async {
  await database.customStatement('''
    CREATE TABLE sync_outbox (
      mutation_id TEXT NOT NULL PRIMARY KEY, account_id TEXT NOT NULL,
      dataset TEXT NOT NULL, entity_id TEXT NOT NULL, operation TEXT NOT NULL,
      payload TEXT NOT NULL, field_mask TEXT NOT NULL, payload_version INTEGER NOT NULL,
      local_revision INTEGER NOT NULL, base_remote_revision TEXT, state TEXT NOT NULL,
      attempt_count INTEGER NOT NULL DEFAULT 0, next_attempt_at INTEGER NOT NULL,
      lease_token TEXT, lease_until INTEGER, created_at INTEGER NOT NULL,
      ${version == 7 ? 'client_updated_at INTEGER NOT NULL,' : ''}
      last_error_code TEXT
    );
  ''');
}

class _LegacySqlDatabase extends GeneratedDatabase {
  _LegacySqlDatabase(super.executor);

  @override
  int get schemaVersion => 1;

  @override
  Iterable<TableInfo<Table, Object?>> get allTables => const [];

  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => const [];
}
