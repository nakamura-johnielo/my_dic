import 'dart:developer';

import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:my_dic/Constants/enviroment.dart';
import 'package:my_dic/_Framework_Driver/Database/drift/DAO/part_of_speech_list_dao.dart';
import 'package:my_dic/_Framework_Driver/Database/drift/DAO/ranking_dao.dart';
import 'package:my_dic/_Framework_Driver/Database/drift/DAO/word_dao.dart';
import 'package:my_dic/_Framework_Driver/Database/drift/Entity/conjugations.dart';
import 'package:my_dic/_Framework_Driver/Database/drift/Entity/dictionaries.dart';
import 'package:my_dic/_Framework_Driver/Database/drift/Entity/examples.dart';
import 'package:my_dic/_Framework_Driver/Database/drift/Entity/idioms.dart';
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
  WordStatus
], daos: [
  WordDao,
  RankingDao,
  PartOfSpeechListDao
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
  int get schemaVersion => 2;

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
      );
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
  final documentsDirectory = await getApplicationDocumentsDirectory();

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

void _setDatabase(String dbName) async {
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
