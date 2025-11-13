import 'dart:developer';

import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:my_dic/Constants/enviroment.dart';
import 'package:my_dic/_Framework_Driver/Database/drift/DAO/es_en_conjugacion_dao.dart';
import 'package:my_dic/_Framework_Driver/Database/drift/DAO/jpn_esp/jpn_esp_word_dao.dart';
import 'package:my_dic/_Framework_Driver/Database/drift/DAO/my_word_dao.dart';
import 'package:my_dic/_Framework_Driver/Database/drift/DAO/part_of_speech_list_dao.dart';
import 'package:my_dic/_Framework_Driver/Database/drift/DAO/ranking_dao.dart';
import 'package:my_dic/_Framework_Driver/Database/drift/DAO/word_dao.dart';
import 'package:my_dic/_Framework_Driver/Database/drift/Entity/conjugations.dart';
import 'package:my_dic/_Framework_Driver/Database/drift/Entity/dictionaries.dart';
import 'package:my_dic/_Framework_Driver/Database/drift/Entity/es_en_conjugacions.dart';
import 'package:my_dic/_Framework_Driver/Database/drift/Entity/examples.dart';
import 'package:my_dic/_Framework_Driver/Database/drift/Entity/idioms.dart';
import 'package:my_dic/_Framework_Driver/Database/drift/Entity/jpn-esp/jpn_esp_dictionaries.dart';
import 'package:my_dic/_Framework_Driver/Database/drift/Entity/jpn-esp/jpn_esp_examples.dart';
import 'package:my_dic/_Framework_Driver/Database/drift/Entity/jpn-esp/jpn_esp_word.dart';
import 'package:my_dic/_Framework_Driver/Database/drift/Entity/jpn-esp/jpn_esp_word_status.dart';
import 'package:my_dic/_Framework_Driver/Database/drift/Entity/my_word_status.dart';
import 'package:my_dic/_Framework_Driver/Database/drift/Entity/my_words.dart';
import 'package:my_dic/_Framework_Driver/Database/drift/Entity/part_of_speech_lists.dart';
import 'package:my_dic/_Framework_Driver/Database/drift/Entity/rankings.dart';
import 'package:my_dic/_Framework_Driver/Database/drift/Entity/supplements.dart';
import 'package:my_dic/_Framework_Driver/Database/drift/Entity/word_status.dart';
import 'package:my_dic/_Framework_Driver/Database/drift/Entity/words.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';

import 'package:flutter/services.dart';
import 'package:path/path.dart';
import 'dart:async';

part '../../../__generated/_Framework_Driver/Database/drift/database_provider.g.dart';

@DriftDatabase(tables: [
  Conjugations,
  Dictionaries,
  Examples,
  Idioms,
  PartOfSpeechLists,
  Rankings,
  Supplements,
  Words,
  WordStatus,
  MyWords,
  MyWordStatus,
  JpnEspWords,
  JpnEspWordStatus,
  JpnEspDictionaries,
  JpnEspExamples,
  EsEnConjugacions,
], daos: [
  WordDao,
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
  int get schemaVersion => 4;
  //2025/11/12
  // EsEnConjugacionsテーブル追加

  @override
  MigrationStrategy get migration {
    return MigrationStrategy(
      onCreate: (Migrator m) async {
        print("==== DB Migration create ===");
        await m.createAll();
      },
      onUpgrade: (Migrator m, int from, int to) async {
        print("==== DB Migration upgrade ===");
        print("DatabaseProvider - onUpgrade from $from to $to");
        if (from < 1) {
          //await m.addColumn(todos, todos.content);
        }
        if (from < 4) {
          await m.createTable(esEnConjugacions);

          // ATTACH 用の軽量サブDB (assets/es_en_conjugacions.db) をコピーしてパス取得
          final attachDbPath = await copyAssetDbOnce('es_en_conjugacions.db');
          await customStatement(
              "ATTACH DATABASE '${attachDbPath.replaceAll(r'\', '/')}' AS seeddb;");
          print("attached database at $attachDbPath");

          try {
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
        }
      },
      beforeOpen: (details) async {
        print("==== DB Migration beforeOpen ===");
        if (details.wasCreated) {
          log("DatabaseProvider - Database was created");
        }
        //===== upgrade時の処理 =====//
        if (details.hadUpgrade) {
          log("DatabaseProvider - Database had upgrade");
          //===ver2=========//
          if (details.versionBefore! < 3) {
            //   // ATTACH 用の軽量サブDB (assets/es_en_conjugacions.db) をコピーしてパス取得
            //   final attachDbPath = await copyAssetDbOnce('es_en_conjugacions.db');
            //   await transaction(() async {
            //     print("start transaction");
            //     await customStatement(
            //         "ATTACH DATABASE '$attachDbPath' AS seeddb;");
            //     print("attached database at $attachDbPath");
            //     await customStatement("""
            //     INSERT INTO es_en_conjugacions (word_id, word, english, present_3rd, present_p, past, past_p)
            //     SELECT word_id, word, english, present_3rd, present_p, past, past_p FROM seeddb.es_en_conjugacions;
            //   """);
            //     await customStatement("DETACH DATABASE seeddb;");
            //     await deleteDatabaseFile(attachDbPath);
            //   });
          }
        }
      },
    );
  }
/*
  @override
  MigrationStrategy get migration => MigrationStrategy(
        onUpgrade: (migrator, from, to) async {
          if (from < to) {
            // スキーマバージョン1からのアップグレード
            _setDatabase(DB_NAME);
          }
        },
        beforeOpen: (details) async {
          if (details.wasCreated || details.hadUpgrade) {
            // 新しいデータベースを上書きする
            // 必要な初期データの挿入など
          }
        },
      ); */
}

// ...existing code...
Future<void> deleteDatabaseFile(String dbName) async {
  final documentsDirectory = await getApplicationSupportDirectory();
  final folderPath = join(documentsDirectory.path, "${APP_NAME}_DB");
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
  // 保存先フォルダ（既存の getDatabasePath と同じ場所）
  final documentsDirectory = await getApplicationSupportDirectory();
  final folderPath = join(documentsDirectory.path, "${APP_NAME}_DB");
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
    final dbPath = await getDatabasePath(DB_NAME);
    log("DatabaseProvider - Database path: $dbPath");
    final file = File(dbPath);
    return NativeDatabase(file);
  });
}

Future<String> getDatabasePath(String dbName) async {
  final documentsDirectory = await getApplicationSupportDirectory();

  // 新しいフォルダのパスを作成
  final folderPath = join(documentsDirectory.path, "${APP_NAME}_DB");
  // 新しいフォルダが存在しない場合は作成
  final folder = Directory(folderPath);
  //await folder.create(recursive: false);
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

  /* ByteData data = await rootBundle.load('assets/$dbName');
  List<int> bytes =
      data.buffer.asUint8List(data.offsetInBytes, data.lengthInBytes);
  await File(dbPath).writeAsBytes(bytes); */
  return dbPath;
}

/* void _setDatabase(String dbName) async {
  final documentsDirectory = await getApplicationDocumentsDirectory();

  // 新しいフォルダのパスを作成
  final folderPath = join(documentsDirectory.path, "${APP_NAME}_DB");
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
  ByteData data = await rootBundle.load('assets/$dbName');
  List<int> bytes =
      data.buffer.asUint8List(data.offsetInBytes, data.lengthInBytes);
  await File(dbPath).writeAsBytes(bytes);
}
 */




/* 
実行コマンド

dart run build_runner clean

dart run build_runner build --delete-conflicting-outputs

 */