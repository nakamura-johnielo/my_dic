import 'dart:developer';

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
import 'package:path_provider/path_provider.dart';

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
], daos: [
  EspJpnWordDao,
  RankingDao,
  PartOfSpeechListDao,
  MyWordDao,
  JpnEspWordDao,
  EsEnConjugacionDao,
])
class DatabaseProvider extends _$DatabaseProvider {
  // シングルトンインスタンスを保持するフィールド
  static DatabaseProvider? _instance;

  // プライベートコンストラクタ
  DatabaseProvider._internal() : super(_openConnection());

  // シングルトンインスタンスを取得するためのファクトリコンストラクタ
  factory DatabaseProvider() {
    return _instance ??= DatabaseProvider._internal();
  }

  @override
  int get schemaVersion => 5;
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
        print("==== DB Migration create ===");
        print("Platform: ${kIsWeb ? 'WEB' : 'NATIVE'}");
        print("🔍 DEBUG: kIsWeb = $kIsWeb");
        await m.createAll();
        print("Tables created successfully");

        // Web環境の場合、JSONからデータをシード
        print("🔍 DEBUG: About to check kIsWeb for seeding...");
        if (kIsWeb) {
          print("🔍 DEBUG: INSIDE kIsWeb block - starting seeding");
          log("🌐 Web platform detected - starting JSON seeding...");
          final startTime = DateTime.now();
          try {
            final seeder = WebDatabaseSeeder(this);
            print("🔍 DEBUG: WebDatabaseSeeder created");
            await seeder.seedFromJson();
            final duration = DateTime.now().difference(startTime);
            log("✅ Web seeding completed in ${duration.inSeconds}s");

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

              print('✅ Database seeding verification:');
              print('   - Words imported: ${wordCount.data['count']}');
              print('   - Dictionaries imported: ${dictCount.data['count']}');
              print('   - Rankings imported: ${rankingCount.data['count']}');
            } catch (e) {
              print('⚠️ Could not verify data import: $e');
            }
          } catch (e, stack) {
            print("❌ ERROR in onCreate seeding: $e");
            print("Stack trace: $stack");
            rethrow;
          }
        } else {
          print("🔍 DEBUG: kIsWeb is FALSE - skipping web seeding");
        }
        print("🔍 DEBUG: onCreate completed");
      },
      onUpgrade: (Migrator m, int from, int to) async {
        print("==== DB Migration upgrade ===");
        print("DatabaseProvider - onUpgrade from $from to $to");
        if (from < 1) {
          //no existing version, so create all tables
        }
        if (from < 4) {
          await m.createTable(esEnConjugacions);

          if (!kIsWeb) {
            // ATTACH 用の軽量サブDB (assets/es_en_conjugacions.db) をコピーしてパス取得
            final attachDbPath = await copyAssetDbOnce('es_en_conjugacions.db');
            await customStatement(
                "ATTACH DATABASE '${attachDbPath.replaceAll(r'\', '/')}' AS seeddb;");
            print("attached database at $attachDbPath");

            try {
              // 挿入済みなら投入不要
              final cnt = await customSelect(
                      "SELECT COUNT(*) AS c FROM es_en_conjugacions;")
                  .getSingle();
              final hasData = (cnt.data['c'] as int) > 0;
              if (hasData) {
                log("Skip seeding es_en_conjugacions (already populated).");
                return;
              }

              await transaction(() async {
                print("start transaction");
                await customStatement("""
                INSERT INTO es_en_conjugacions (word_id, word, english, present_3rd, present_p, past, past_p)
                SELECT word_id, word, english, present_3rd, present_p, past, past_p FROM seeddb.es_en_conjugacions;
              """);
              });
            } finally {
              await customStatement("DETACH DATABASE seeddb;");
              await deleteDatabaseFile(attachDbPath);
            }
          } else {
            log("Web platform: es_en_conjugacions seeding skipped - needs web implementation");
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
            log("MyWords.my_word_id is already TEXT; skipping UUID migration.");
          } else {
            await transaction(() async {
              log('Migrating MyWord IDs from INTEGER to UUID(TEXT)...');

              // Rename legacy tables
              await customStatement(
                  'ALTER TABLE my_words RENAME TO my_words_old;');
              try {
                await customStatement(
                    'ALTER TABLE my_word_status RENAME TO my_word_status_old;');
              } catch (_) {
                // Status table may not exist in some environments.
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
                await into(myWords).insert(
                  MyWordsCompanion.insert(
                    myWordId: row.data['my_word_id'].toString(),
                    word: row.data['word']?.toString() ?? '',
                    contents: Value(row.data['contents']?.toString()),
                    editAt: row.data['edit_at']?.toString() ?? '',
                  ),
                );
              }

              // Migrate statuses using the same mapping
              try {
                final oldStatuses = await customSelect(
                  'SELECT my_word_id, is_learned, is_bookmarked, has_note, edit_at FROM my_word_status_old;',
                ).get();

                for (final row in oldStatuses) {
                  final oldId = row.data['my_word_id'].toString();
                  final newId = idMap[oldId];
                  if (newId == null) {
                    continue;
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
              } catch (_) {
                // If there was no old status table, nothing to migrate.
              }

              // Drop old tables
              await customStatement('DROP TABLE my_words_old;');
              try {
                await customStatement('DROP TABLE my_word_status_old;');
              } catch (_) {
                // ignore
              }

              log('MyWord UUID migration completed.');
            });
          }
        }
      },
      beforeOpen: (details) async {
        print("==== DB Migration beforeOpen ===");
        print("Platform: ${kIsWeb ? 'WEB (IndexedDB)' : 'NATIVE (SQLite)'}");
        print("==== DB version is ${details.versionNow} ===");
        if (details.wasCreated) {
          log("🆕 DatabaseProvider - Database was created (first time)");
        } else {
          log("📂 DatabaseProvider - Opening existing database");
        }
        //===== upgrade時の処理 =====//
        if (details.hadUpgrade) {
          log("DatabaseProvider - Database had upgrade");
          //===ver2=========//
          if (details.versionBefore! < 3) {
            // ATTACH 用の軽量サブDB (assets/es_en_conjugacions.db) をコピーしてパス取得
          }
        }
      },
    );
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
    log("deleteDatabaseFile called on web - no-op");
    return;
  }
  final folderPath = await getAppDir();
  final dbPath = join(folderPath, dbName);
  final dbFile = File(dbPath);

  if (await dbFile.exists()) {
    await dbFile.delete();
    log("Database file deleted at: $dbPath");
  } else {
    log("No database file found to delete at: $dbPath");
  }
}

Future<String> copyAssetDbOnce(String assetDbFileName,
    {String? destFileName}) async {
  if (kIsWeb) {
    log("copyAssetDbOnce called on web - returning placeholder");
    return 'web_not_supported';
  }
  // 保存先フォルダ（既存の getDatabasePath と同じ場所）
  final folderPath = await getAppDir();
  final folder = Directory(folderPath);
  if (!await folder.exists()) {
    await folder.create(recursive: true);
    log("Folder created at: $folderPath");
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
  print("Asset database copied to: $destPath");
  return destPath;
}

LazyDatabase _openConnection() {
  return LazyDatabase(() async {
    if (kIsWeb) {
      // Web: Use WasmDatabase (IndexedDB)
      log("DatabaseProvider - Using WasmDatabase for web platform");
      return await createWebExecutor('my_dic_db');
    } else {
      // Mobile/Desktop: Use file-based SQLite
      final dbPath = await getDatabasePath(DB_NAME);
      log("DatabaseProvider - Database path: $dbPath");
      final file = File(dbPath);
      return await createNativeExecutor(file);
    }
  });
}

Future<String> getDatabasePath(String dbName) async {
  if (kIsWeb) {
    // Web doesn't need file paths - IndexedDB is used instead
    log("getDatabasePath called on web platform - returning placeholder");
    return 'web_indexeddb';
  }

  final folderPath = await getAppDir();

  // 新しいフォルダが存在しない場合は作成
  final folder = Directory(folderPath);
  if (!await folder.exists()) {
    await folder.create(recursive: true);
    log("Folder created at: $folderPath");
  } else {
    log("Folder already exists at: $folderPath");
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
