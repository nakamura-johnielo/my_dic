import 'package:drift/drift.dart';
import 'package:flutter/foundation.dart';
import 'package:my_dic/core/shared/consts/enviroment.dart';
import 'dart:io'
    if (dart.library.html) 'package:my_dic/core/infrastructure/database/drift/_WEB/io_stub.dart';
import 'package:my_dic/core/infrastructure/database/drift/_NATIVE/native_database_helper.dart'
    if (dart.library.html) 'package:my_dic/core/infrastructure/database/drift/_NATIVE/native_database_helper_web.dart';
import 'package:my_dic/core/infrastructure/database/drift/_WEB/web_executor.dart'
    if (dart.library.io) 'package:my_dic/core/infrastructure/database/drift/_WEB/web_executor_stub.dart';
import 'package:my_dic/core/infrastructure/database/drift/daos/es_en_conjugacion_dao.dart';
import 'package:my_dic/core/infrastructure/database/drift/daos/jpn_esp/jpn_esp_word_dao.dart';
import 'package:my_dic/features/my_word/data/data_source/local/drift_my_word_dao.dart';
import 'package:my_dic/core/infrastructure/database/drift/daos/esp_jpn/part_of_speech_list_dao.dart';
import 'package:my_dic/features/ranking/data/data_source/local/ranking_dao.dart';
import 'package:my_dic/core/infrastructure/database/drift/daos/esp_jpn/esp_jpn_word_dao.dart';
import 'package:my_dic/core/infrastructure/database/drift/tables/esp_jpn/conjugations.dart';
import 'package:my_dic/core/infrastructure/database/drift/tables/esp_jpn/dictionaries.dart';
import 'package:my_dic/core/infrastructure/database/drift/tables/es_en_conjugacions.dart';
import 'package:my_dic/core/infrastructure/database/drift/tables/esp_jpn/examples.dart';
import 'package:my_dic/core/infrastructure/database/drift/tables/esp_jpn/idioms.dart';
import 'package:my_dic/core/infrastructure/database/drift/tables/jpn-esp/jpn_esp_dictionaries.dart';
import 'package:my_dic/core/infrastructure/database/drift/tables/jpn-esp/jpn_esp_examples.dart';
import 'package:my_dic/core/infrastructure/database/drift/tables/jpn-esp/jpn_esp_word.dart';
import 'package:my_dic/core/infrastructure/database/drift/tables/jpn-esp/jpn_esp_word_status.dart';
import 'package:my_dic/features/my_word/data/data_source/local/my_word_status.dart';
import 'package:my_dic/features/my_word/data/data_source/local/my_words.dart';
import 'package:my_dic/core/infrastructure/database/drift/tables/esp_jpn/part_of_speech_lists.dart';
import 'package:my_dic/features/ranking/data/data_source/local/rankings_entity.dart';
import 'package:my_dic/core/infrastructure/database/drift/tables/esp_jpn/supplements.dart';
import 'package:my_dic/core/infrastructure/database/drift/tables/esp_jpn/word_status.dart';
import 'package:my_dic/core/infrastructure/database/drift/tables/esp_jpn/words.dart';
import 'package:my_dic/core/infrastructure/database/drift/tables/sync/sync_outbox.dart';
import 'package:my_dic/core/infrastructure/database/drift/tables/sync/sync_checkpoints.dart';
import 'package:my_dic/core/infrastructure/database/drift/tables/sync/user_profiles.dart';
import 'package:path_provider/path_provider.dart';
import 'package:my_dic/core/shared/utils/logger.dart';

import 'package:flutter/services.dart';
import 'package:path/path.dart';
import 'dart:async';
import 'package:my_dic/core/infrastructure/database/drift/_WEB/web_database_seeder.dart'
    if (dart.library.io) 'package:my_dic/core/infrastructure/database/drift/_WEB/web_database_seeder_stub.dart';

part '../../../../__generated/core/infrastructure/database/drift/database_provider.g.dart';

//==========================-

// 実行コマンド

// dart run build_runner clean

// dart run build_runner build --delete-conflicting-outputs

//==========================

@DriftDatabase(tables: [
  EspConjugations,
  EspJpnDictionaries,
  EspJpnExamples,
  EspJpnIdioms,
  PartOfSpeechLists,
  Rankings,
  EspJpnSupplements,
  EspJpnWords,
  EspJpnWordStatus,
  MyWords,
  MyWordStatus,
  JpnEspWords,
  JpnEspWordStatus,
  JpnEspDictionaries,
  JpnEspExamples,
  EsEnConjugacions,
  SyncOutbox,
  SyncCheckpoints,
  UserProfiles,
], daos: [
  EspJpnWordDao,
  RankingDao,
  PartOfSpeechListDao,
  MyWordDao,
  JpnEspWordDao,
  EsEnConjugacionDao,
])
class DatabaseProvider extends _$DatabaseProvider {
  /// A database instance is owned by the Riverpod provider that creates it.
  ///
  /// Keeping this constructor non-singleton lets each ProviderContainer (and
  /// each test) manage its own connection and disposal lifecycle.
  DatabaseProvider()
      : _seedEsEnConjugacionsOnUpgrade = true,
        super(_openConnection());

  /// Opens a caller-provided database for migration tests.
  DatabaseProvider.forTesting(
    super.executor, {
    bool seedEsEnConjugacionsOnUpgrade = false,
  }) : _seedEsEnConjugacionsOnUpgrade = seedEsEnConjugacionsOnUpgrade;

  final bool _seedEsEnConjugacionsOnUpgrade;

  @override
  int get schemaVersion => 6;
  //==============================================================
  //2025/11/12
  // EsEnConjugacionsテーブル追加
  // 2026/01/xx
  // MyWord ID migration: INTEGER -> UUID(TEXT)
  //============================================================

  @override
  MigrationStrategy get migration {
    return MigrationStrategy(
      onCreate: (Migrator m) async {
        AppLogger.print("==== DB Migration create ===");
        AppLogger.print("Platform: ${kIsWeb ? 'WEB' : 'NATIVE'}");
        AppLogger.print("🔍 DEBUG: kIsWeb = $kIsWeb");
        await m.createAll();
        await _createSyncOutboxIndexes();
        AppLogger.print("Tables created successfully");

        // Web環境の場合、JSONからデータをシード
        AppLogger.print("🔍 DEBUG: About to check kIsWeb for seeding...");
        if (kIsWeb) {
          AppLogger.print("🔍 DEBUG: INSIDE kIsWeb block - starting seeding");
          AppLogger.print(
              "🌐 Web platform detected - starting JSON seeding...");
          final startTime = DateTime.now();
          try {
            final seeder = WebDatabaseSeeder(this);
            AppLogger.print("🔍 DEBUG: WebDatabaseSeeder created");
            await seeder.seedFromJson();
            final duration = DateTime.now().difference(startTime);
            AppLogger.print(
                "✅ Web seeding completed in ${duration.inSeconds}s");

            // データが正常にインポートされたか確認
            try {
              final wordCount =
                  await customSelect('SELECT COUNT(*) as count FROM words')
                      .getSingle();
              final dictCount = await customSelect(
                      'SELECT COUNT(*) as count FROM dictionaries')
                  .getSingle();
              final rankingCount =
                  await customSelect('SELECT COUNT(*) as count FROM rankings')
                      .getSingle();

              AppLogger.print('✅ Database seeding verification:');
              AppLogger.print(
                  '   - Words imported: ${wordCount.data['count']}');
              AppLogger.print(
                  '   - Dictionaries imported: ${dictCount.data['count']}');
              AppLogger.print(
                  '   - Rankings imported: ${rankingCount.data['count']}');
            } catch (e) {
              AppLogger.print('⚠️ Could not verify data import: $e');
            }
          } catch (e, stack) {
            AppLogger.print("❌ ERROR in onCreate seeding: $e");
            AppLogger.print("Stack trace: $stack");
            rethrow;
          }
        } else {
          AppLogger.print("🔍 DEBUG: kIsWeb is FALSE - skipping web seeding");
        }
        AppLogger.print("🔍 DEBUG: onCreate completed");
      },
      onUpgrade: (Migrator m, int from, int to) async {
        AppLogger.print("==== DB Migration upgrade ===");
        AppLogger.print("DatabaseProvider - onUpgrade from $from to $to");
        if (from < 1) {
          //no existing version, so create all tables
        }
        if (from < 4) {
          await m.createTable(esEnConjugacions);

          if (!kIsWeb && _seedEsEnConjugacionsOnUpgrade) {
            // ATTACH 用の軽量サブDB (assets/es_en_conjugacions.db) をコピーしてパス取得
            final attachDbPath = await copyAssetDbOnce('es_en_conjugacions.db');
            await customStatement(
                "ATTACH DATABASE '${attachDbPath.replaceAll(r'\', '/')}' AS seeddb;");
            AppLogger.print("attached database at $attachDbPath");

            try {
              // 挿入済みなら投入不要
              final cnt = await customSelect(
                      "SELECT COUNT(*) AS c FROM es_en_conjugacions;")
                  .getSingle();
              final hasData = (cnt.data['c'] as int) > 0;
              if (hasData) {
                AppLogger.print(
                    "Skip seeding es_en_conjugacions (already populated).");
              } else {
                await transaction(() async {
                  AppLogger.print("start transaction");
                  await customStatement("""
                  INSERT INTO es_en_conjugacions (word_id, word, english, present_3rd, present_p, past, past_p)
                  SELECT word_id, word, english, present_3rd, present_p, past, past_p FROM seeddb.es_en_conjugacions;
                """);
                });
              }
            } finally {
              await customStatement("DETACH DATABASE seeddb;");
              await deleteDatabaseFile(attachDbPath);
            }
          } else if (kIsWeb) {
            AppLogger.print(
                "Web platform: es_en_conjugacions seeding skipped - needs web implementation");
          }
        }

        if (from < 5) {
          // If the DB was created after the UUID change but before version bump,
          // tables are already TEXT and we must NOT remap IDs.
          final myWordsInfo =
              await customSelect("PRAGMA table_info('my_words');").get();
          String? myWordIdType;
          for (final row in myWordsInfo) {
            if (row.data['name'] == 'my_word_id') {
              myWordIdType = row.data['type']?.toString();
              break;
            }
          }

          final normalizedType = (myWordIdType ?? '').toUpperCase();
          final needsIdMigration = normalizedType.contains('INT');
          if (!needsIdMigration) {
            AppLogger.print(
                "MyWords.my_word_id is already TEXT; skipping UUID migration.");
          } else {
            await transaction(() async {
              AppLogger.print(
                  'Migrating MyWord IDs from INTEGER to UUID(TEXT)...');

              final legacyStatusExists = (await customSelect(
                "SELECT 1 FROM sqlite_master WHERE type = 'table' AND name = 'my_word_status';",
              ).get())
                  .isNotEmpty;

              // Rename legacy tables
              await customStatement(
                  'ALTER TABLE my_words RENAME TO my_words_old;');
              if (legacyStatusExists) {
                await customStatement(
                    'ALTER TABLE my_word_status RENAME TO my_word_status_old;');
              }

              // Create new tables using current schema
              await m.createTable(myWords);
              await m.createTable(myWordStatus);

              // Build mapping oldId -> newUuid
              final idMap = <String, String>{};
              final oldWords = await customSelect(
                'SELECT my_word_id, word, contents, edit_at FROM my_words_old;',
              ).get();

              for (final row in oldWords) {
                final oldId = row.data['my_word_id'].toString();
                final newId = oldId;
                idMap[oldId] = newId;
                await into(myWords).insert(
                  MyWordsCompanion.insert(
                    myWordId: newId,
                    word: row.data['word']?.toString() ?? '',
                    contents: Value(row.data['contents']?.toString()),
                    editAt: row.data['edit_at']?.toString() ?? '',
                  ),
                );
              }

              final migratedWordCount = await customSelect(
                'SELECT COUNT(*) AS count FROM my_words;',
              ).getSingle();
              if (migratedWordCount.data['count'] != oldWords.length ||
                  idMap.length != oldWords.length) {
                throw StateError('Not all MyWords were migrated.');
              }

              // An unmapped status is a corrupt legacy relation. Failing the
              // transaction keeps both legacy tables intact for recovery.
              if (legacyStatusExists) {
                final oldStatuses = await customSelect(
                  'SELECT my_word_id, is_learned, is_bookmarked, has_note, edit_at FROM my_word_status_old;',
                ).get();

                for (final row in oldStatuses) {
                  final oldId = row.data['my_word_id'].toString();
                  final newId = idMap[oldId];
                  if (newId == null) {
                    throw StateError(
                      'Cannot migrate MyWord status with missing MyWord ID.',
                    );
                  }

                  await into(myWordStatus).insert(
                    MyWordStatusCompanion.insert(
                      myWordId: newId,
                      editAt: row.data['edit_at']?.toString() ?? '',
                      isLearned: Value(row.data['is_learned'] as int?),
                      isBookmarked: Value(row.data['is_bookmarked'] as int?),
                      hasNote: Value(row.data['has_note'] as int?),
                    ),
                  );
                }

                final migratedStatusCount = await customSelect(
                  'SELECT COUNT(*) AS count FROM my_word_status;',
                ).getSingle();
                if (migratedStatusCount.data['count'] != oldStatuses.length) {
                  throw StateError('Not all MyWord statuses were migrated.');
                }
              }

              // Drop old tables
              await customStatement('DROP TABLE my_words_old;');
              if (legacyStatusExists) {
                await customStatement('DROP TABLE my_word_status_old;');
              }

              AppLogger.print('MyWord UUID migration completed.');
            });
          }
        }

        if (from < 6) {
          await _migrateUserOwnedTablesToV6();
          await m.createTable(syncOutbox);
          await m.createTable(syncCheckpoints);
          await m.createTable(userProfiles);
          await _createSyncOutboxIndexes();
        }
      },
      beforeOpen: (details) async {
        AppLogger.print("==== DB Migration beforeOpen ===");
        AppLogger.print(
            "Platform: ${kIsWeb ? 'WEB (IndexedDB)' : 'NATIVE (SQLite)'}");
        AppLogger.print("==== DB version is ${details.versionNow} ===");
        if (details.wasCreated) {
          AppLogger.print(
              "🆕 DatabaseProvider - Database was created (first time)");
        } else {
          AppLogger.print("📂 DatabaseProvider - Opening existing database");
        }
        //===== upgrade時の処理 =====//
        if (details.hadUpgrade) {
          AppLogger.print("DatabaseProvider - Database had upgrade");
          //===ver2=========//
          if (details.versionBefore! < 3) {
            // ATTACH 用の軽量サブDB (assets/es_en_conjugacions.db) をコピーしてパス取得
          }
        }
      },
    );
  }
}

extension on DatabaseProvider {
  Future<void> _createSyncOutboxIndexes() async {
    await customStatement(
        'CREATE INDEX IF NOT EXISTS sync_outbox_pending_idx ON sync_outbox (account_id, dataset, state, next_attempt_at, created_at)');
    await customStatement(
        'CREATE INDEX IF NOT EXISTS sync_outbox_entity_idx ON sync_outbox (account_id, dataset, entity_id, state)');
    await customStatement(
        'CREATE INDEX IF NOT EXISTS sync_outbox_lease_idx ON sync_outbox (lease_until, state)');
  }

  Future<void> _migrateUserOwnedTablesToV6() async {
    await _rebuildOwnedTable(
      table: 'my_words',
      createSql: '''CREATE TABLE my_words_v6 (
        my_word_id TEXT NOT NULL, word TEXT NOT NULL, contents TEXT,
        edit_at TEXT NOT NULL, account_id TEXT NOT NULL,
        local_revision INTEGER NOT NULL DEFAULT 0, remote_revision TEXT,
        deleted_at INTEGER, last_mutation_id TEXT,
        PRIMARY KEY (account_id, my_word_id), CHECK (account_id <> ''))''',
      columns: const ['my_word_id', 'word', 'contents', 'edit_at'],
    );
    await _rebuildOwnedTable(
      table: 'my_word_status',
      createSql: '''CREATE TABLE my_word_status_v6 (
        my_word_id TEXT NOT NULL, is_learned INTEGER, is_bookmarked INTEGER,
        has_note INTEGER, edit_at TEXT NOT NULL, account_id TEXT NOT NULL,
        local_revision INTEGER NOT NULL DEFAULT 0, remote_revision TEXT,
        deleted_at INTEGER, last_mutation_id TEXT,
        PRIMARY KEY (account_id, my_word_id), CHECK (account_id <> ''))''',
      columns: const [
        'my_word_id',
        'is_learned',
        'is_bookmarked',
        'has_note',
        'edit_at'
      ],
    );
    await _rebuildOwnedTable(
      table: 'word_status',
      createSql: '''CREATE TABLE word_status_v6 (
        word_id INTEGER NOT NULL, is_learned INTEGER, is_bookmarked INTEGER,
        has_note INTEGER, edit_at TEXT NOT NULL, account_id TEXT NOT NULL,
        local_revision INTEGER NOT NULL DEFAULT 0, remote_revision TEXT,
        deleted_at INTEGER, last_mutation_id TEXT,
        PRIMARY KEY (account_id, word_id),
        FOREIGN KEY (word_id) REFERENCES words (word_id) ON DELETE CASCADE,
        CHECK (account_id <> ''))''',
      columns: const [
        'word_id',
        'is_learned',
        'is_bookmarked',
        'has_note',
        'edit_at'
      ],
    );
    await _rebuildOwnedTable(
      table: 'jpn_esp_word_status',
      createSql: '''CREATE TABLE jpn_esp_word_status_v6 (
        jpn_esp_word_id INTEGER NOT NULL, is_learned INTEGER,
        is_bookmarked INTEGER, has_note INTEGER, edit_at TEXT NOT NULL,
        account_id TEXT NOT NULL, local_revision INTEGER NOT NULL DEFAULT 0,
        remote_revision TEXT, deleted_at INTEGER, last_mutation_id TEXT,
        PRIMARY KEY (account_id, jpn_esp_word_id),
        FOREIGN KEY (jpn_esp_word_id) REFERENCES jpn_esp_words (jpn_esp_word_id) ON DELETE CASCADE,
        CHECK (account_id <> ''))''',
      columns: const [
        'jpn_esp_word_id',
        'is_learned',
        'is_bookmarked',
        'has_note',
        'edit_at'
      ],
    );
  }

  Future<void> _rebuildOwnedTable({
    required String table,
    required String createSql,
    required List<String> columns,
  }) async {
    final exists = await customSelect(
      "SELECT 1 FROM sqlite_master WHERE type='table' AND name='$table'",
    ).getSingleOrNull();
    if (exists == null) return;
    final info = await customSelect("PRAGMA table_info('$table')").get();
    final accountPk = info.any((row) =>
        row.data['name'] == 'account_id' && (row.data['pk'] as int? ?? 0) > 0);
    if (accountPk) return;
    final shadow = '${table}_v6';
    await customStatement('DROP TABLE IF EXISTS $shadow');
    await customStatement(createSql);
    final columnList = columns.join(', ');
    await customStatement('''INSERT INTO $shadow
      ($columnList, account_id, local_revision)
      SELECT $columnList, 'legacy_unowned', 0 FROM $table''');
    final before =
        await customSelect('SELECT COUNT(*) AS c FROM $table').getSingle();
    final after =
        await customSelect('SELECT COUNT(*) AS c FROM $shadow').getSingle();
    if (before.data['c'] != after.data['c']) {
      throw StateError('Row count mismatch while migrating $table');
    }
    await customStatement('DROP TABLE $table');
    await customStatement('ALTER TABLE $shadow RENAME TO $table');
  }
}

Future<String> getAppDir() async {
  if (kIsWeb) {
    return 'web_indexeddb';
  }
  final documentsDirectory = await getApplicationSupportDirectory();
  final path = kReleaseMode
      ? join(documentsDirectory.path, "${APP_NAME}_DB")
      : join(documentsDirectory.path, "DEBUG", "${APP_NAME}_DB");
  return path;
}

Future<void> deleteDatabaseFile(String dbName) async {
  if (kIsWeb) {
    AppLogger.print("deleteDatabaseFile called on web - no-op");
    return;
  }
  final folderPath = await getAppDir();
  final dbPath = join(folderPath, dbName);
  final dbFile = File(dbPath);

  if (await dbFile.exists()) {
    await dbFile.delete();
    AppLogger.print("Database file deleted at: $dbPath");
  } else {
    AppLogger.print("No database file found to delete at: $dbPath");
  }
}

Future<String> copyAssetDbOnce(String assetDbFileName,
    {String? destFileName}) async {
  if (kIsWeb) {
    AppLogger.print("copyAssetDbOnce called on web - returning placeholder");
    return 'web_not_supported';
  }
  // 保存先フォルダ（既存の getDatabasePath と同じ場所）
  final folderPath = await getAppDir();
  final folder = Directory(folderPath);
  if (!await folder.exists()) {
    await folder.create(recursive: true);
    AppLogger.print("Folder created at: $folderPath");
  }

  final targetName = destFileName ?? assetDbFileName; // 名前を変えたい場合に指定可
  final destPath = join(folder.path, targetName);
  final destFile = File(destPath);

  if (await destFile.exists()) {
    return destPath; // 既にコピー済みならそのまま返す
  }

  // assets からコピー
  final data = await rootBundle.load('assets/$assetDbFileName');
  final bytes = data.buffer.asUint8List(data.offsetInBytes, data.lengthInBytes);
  await destFile.writeAsBytes(bytes, flush: true);
  AppLogger.print("Asset database copied to: $destPath");
  return destPath;
}

LazyDatabase _openConnection() {
  return LazyDatabase(() async {
    if (kIsWeb) {
      // Web: Use WasmDatabase (IndexedDB)
      AppLogger.print("DatabaseProvider - Using WasmDatabase for web platform");
      return await createWebExecutor('my_dic_db');
    } else {
      // Mobile/Desktop: Use file-based SQLite
      final dbPath = await getDatabasePath(DB_NAME);
      AppLogger.print("DatabaseProvider - Database path: $dbPath");
      final file = File(dbPath);
      return await createNativeExecutor(file);
    }
  });
}

Future<String> getDatabasePath(String dbName) async {
  if (kIsWeb) {
    // Web doesn't need file paths - IndexedDB is used instead
    AppLogger.print(
        "getDatabasePath called on web platform - returning placeholder");
    return 'web_indexeddb';
  }

  final folderPath = await getAppDir();

  // 新しいフォルダが存在しない場合は作成
  final folder = Directory(folderPath);
  if (!await folder.exists()) {
    await folder.create(recursive: true);
    AppLogger.print("Folder created at: $folderPath");
  } else {
    AppLogger.print("Folder already exists at: $folderPath");
  }

  // データベースファイルのパスを作成
  final dbPath = join(folder.path, dbName);
  // データベースが存在しない場合にコピー
  if (!await File(dbPath).exists()) {
    ByteData data = await rootBundle.load('assets/$dbName');
    List<int> bytes =
        data.buffer.asUint8List(data.offsetInBytes, data.lengthInBytes);
    await File(dbPath).writeAsBytes(bytes);
    return dbPath;
  }
  return dbPath;
}
