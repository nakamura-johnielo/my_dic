/// Web用データベースシーディングヘルパー
/// Gzip圧縮JSONからDriftデータベースにデータをインポート
///
/// 注意: このファイルはWeb環境専用です
/// データベーススキーマと完全に同期している必要があります
library;

import 'dart:convert';
import 'package:my_dic/core/shared/utils/logger.dart';
import 'package:archive/archive.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:drift/drift.dart';
import 'package:my_dic/core/composition/global.dart';
import 'package:my_dic/core/infrastructure/database/drift/database_provider.dart';
import 'package:my_dic/core/shared/consts/enviroment.dart';
import 'package:my_dic/core/shared/enums/web/db.dart';

class WebDatabaseSeeder {
  final DatabaseProvider db;
  //final void Function(double? progress, String? message, WebDBLoadingType? type)? onProgress;

  WebDatabaseSeeder(this.db);

  int _totalRows = 120000;
  int _currentRows = 0;
  void _updateProgress(
      {double? progress, String? message, WebDBLoadingType? type}) {
    globalDatabaseLoadingNotifier.updateProgress(progress, message, type);
  }

  void _completeProgress(String? message) {
    globalDatabaseLoadingNotifier.complete(message);
  }

  /// JSON値を安全にint型に変換
  int? _toInt(dynamic value) {
    if (value == null) return null;
    if (value is int) return value;
    if (value is String) return int.tryParse(value);
    if (value is num) return value.toInt();
    return null;
  }

  /// 必須int値（nullを0にフォールバック）
  int _toIntRequired(dynamic value, {int defaultValue = 0}) {
    return _toInt(value) ?? defaultValue;
  }

  /// JSON値を安全にString型に変換
  String? _toString(dynamic value) {
    if (value == null) return null;
    if (value is String) return value;
    if (value is num) {
      if (value is int) return value.toString();
      // double型でも整数を表す場合は、整数形式を維持する
      if (value == value.toInt()) return value.toInt().toString();
      return value.toString();
    }
    return value.toString();
  }

  /// 必須String値（nullをdefaultValueにフォールバック）
  String _toStringRequired(dynamic value, {String defaultValue = ''}) {
    return _toString(value) ?? defaultValue;
  }

  /// Web環境でデータベースをシードする
  Future<void> seedFromJson() async {
    AppLogger.print('🚀 WebDatabaseSeeder.seedFromJson() CALLED');
    AppLogger.print(
        '🚀 WebDatabaseSeeder: Starting database seeding from compressed JSON...');
    AppLogger.print('⚠️ This is first-time setup and may take 2-5 minutes');

    try {
      AppLogger.print('📦 Step 1: Loading kotobank data...');
      await _seedKotobankData();
      AppLogger.print('📦 Step 2: Loading es_en_conjugacions data...');
      await _seedEsEnConjugacions();
      AppLogger.print('✅ WebDatabaseSeeder: Seeding completed successfully');
      AppLogger.print('✅ WebDatabaseSeeder.seedFromJson() COMPLETED');
      _completeProgress('データベース初期化完了');
    } catch (e, stackTrace) {
      AppLogger.print('❌ WebDatabaseSeeder ERROR: $e');
      AppLogger.print('❌ WebDatabaseSeeder: Error - $e');
      AppLogger.print('StackTrace: $stackTrace');
      rethrow;
    }
  }

  Future<Map<String, dynamic>> _loadCompressedJson(String assetPath) async {
    AppLogger.print('📂 Loading compressed JSON: $assetPath');
    AppLogger.print('Loading: $assetPath');
    _updateProgress(
        message: '($assetPath) compressed JSON ダウンロード中...',
        type: WebDBLoadingType.download);
    await Future.delayed(Duration.zero);
    final byteData = await rootBundle.load(assetPath);
    // UIスレッドに制御を返してプログレスアニメーションを開始させる
    await Future.delayed(Duration.zero);
    _updateProgress(
        message: '($assetPath) compressed JSON 展開中...',
        type: WebDBLoadingType.decompressed);
    await Future.delayed(Duration.zero);
    final compressed = byteData.buffer.asUint8List();
    await Future.delayed(Duration.zero);
    AppLogger.print(
        '  Compressed size: ${(compressed.length / 1024 / 1024).toStringAsFixed(2)} MB');
    AppLogger.print(
        '  Compressed size: ${(compressed.length / 1024 / 1024).toStringAsFixed(2)} MB');

    AppLogger.print('  Decompressing...');
    await Future.delayed(Duration.zero);
    final decompressed = GZipDecoder().decodeBytes(compressed);
    // 展開完了後、UIスレッドに制御を返す
    await Future.delayed(Duration.zero);
    _updateProgress(
        message: '($assetPath) jsonデコード中...', type: WebDBLoadingType.parsing);
    await Future.delayed(Duration.zero);
    AppLogger.print(
        '  Decompressed: ${(decompressed.length / 1024 / 1024).toStringAsFixed(2)} MB');
    AppLogger.print(
        '  Decompressed: ${(decompressed.length / 1024 / 1024).toStringAsFixed(2)} MB');

    AppLogger.print('  Parsing JSON...');
    final jsonString = utf8.decode(decompressed);
    final result = jsonDecode(jsonString) as Map<String, dynamic>;
    // JSONパース完了後、UIスレッドに制御を返す
    await Future.delayed(Duration.zero);
    _updateProgress(
        message: '($assetPath) import開始',
        type: WebDBLoadingType.import,
        progress: 0);
    await Future.delayed(Duration.zero);
    AppLogger.print('  ✓ JSON parsed successfully');
    return result;
  }

  Future<void> _setTotalTableRows(Map<String, dynamic> tables) async {
    for (final table in tables.keys.toList()) {
      try {
        final tableData = tables[table];
        final rows = tableData['rows'] as List;
        _totalRows += rows.length;
        AppLogger.print('🔍 Table "$table" has ${rows.length} rows.');
      } catch (e) {
        AppLogger.print(
            '❌ Failed to retrieve row count for table "$table": $e');
      }
    }
    AppLogger.print('✅ Row count retrieval completed.');
  }

  Future<void> _seedKotobankData() async {
    AppLogger.print('🔍 _seedKotobankData() START');
    final data = await _loadCompressedJson(WebDb.kotobankPath);
    AppLogger.print('🔍 JSON loaded, extracting tables...');
    final tables = data['tables'] as Map<String, dynamic>;
    await _setTotalTableRows(tables);
    AppLogger.print('🔍 Tables keys: ${tables.keys.toList()}');

    // 外部キー依存関係を考慮した順序でインポートする
    AppLogger.print('🔍 Checking for "words" table...');
    if (tables.containsKey('words')) {
      AppLogger.print('🔍 Found "words" table, importing...');
      await _importWords(tables['words']);
    } else {
      AppLogger.print('❌ "words" table NOT FOUND');
    }

    AppLogger.print('🔍 Checking for "dictionaries" table...');
    if (tables.containsKey('dictionaries')) {
      AppLogger.print('🔍 Found "dictionaries" table, importing...');
      await _importDictionaries(tables['dictionaries']);
    } else {
      AppLogger.print('❌ "dictionaries" table NOT FOUND');
    }
    if (tables.containsKey('part_of_speech_lists')) {
      await _importPartOfSpeechLists(tables['part_of_speech_lists']);
    }
    if (tables.containsKey('examples')) {
      await _importExamples(tables['examples']);
    }
    if (tables.containsKey('idioms')) {
      await _importIdioms(tables['idioms']);
    }
    if (tables.containsKey('supplements')) {
      await _importSupplements(tables['supplements']);
    }
    if (tables.containsKey('conjugations')) {
      await _importConjugations(tables['conjugations']);
    }
    if (tables.containsKey('jpn_esp_words')) {
      await _importJpnEspWords(tables['jpn_esp_words']);
    }
    if (tables.containsKey('jpn_esp_dictionaries')) {
      await _importJpnEspDictionaries(tables['jpn_esp_dictionaries']);
    }
    if (tables.containsKey('jpn_esp_examples')) {
      await _importJpnEspExamples(tables['jpn_esp_examples']);
    }
    if (tables.containsKey('rankings')) {
      await _importRankings(tables['rankings']);
    }
    if (tables.containsKey('word_status')) {
      await _importEspJpnWordStatus(tables['word_status']);
    }
    if (tables.containsKey('my_words')) {
      await _importMyWords(tables['my_words']);
    }
    if (tables.containsKey('my_word_status')) {
      await _importMyWordStatus(tables['my_word_status']);
    }
    if (tables.containsKey('jpn_esp_word_status')) {
      await _importJpnEspWordStatus(tables['jpn_esp_word_status']);
    }
  }

  Future<void> _seedEsEnConjugacions() async {
    final data = await _loadCompressedJson(WebDb.esEnConjugacionsPath);
    final tables = data['tables'] as Map<String, dynamic>;
    await _setTotalTableRows(tables);
    if (tables.containsKey('es_en_conjugacions')) {
      await _importEsEnConjugacions(tables['es_en_conjugacions']);
    }
  }

  // インポートを簡略化する。Web環境では詳細なログは不要
  Future<void> _importWords(Map<String, dynamic> tableData) async {
    AppLogger.print('🔍 _importWords() CALLED');
    final rows = tableData['rows'] as List;
    AppLogger.print('🔍 _importWords: rows count = ${rows.length}');
    AppLogger.print('Importing ${rows.length} words...');
    const batchSize = 500;
    for (var i = 0; i < rows.length; i += batchSize) {
      _updateProgress(
          message: 'word table 初期化中...',
          type: WebDBLoadingType.import,
          progress: (_currentRows / _totalRows));
      _currentRows += batchSize;
      AppLogger.print(
          '🔍 _importWords: Processing batch ${i ~/ batchSize + 1}/${(rows.length / batchSize).ceil()}');
      final batch = rows.skip(i).take(batchSize).toList();
      await db.batch((b) {
        for (final row in batch) {
          // 必須フィールドがない行はスキップする
          if (row['word_id'] == null || row['word'] == null) continue;
          b.insert(
              db.espJpnWords,
              EspJpnWordsCompanion.insert(
                wordId: Value(_toIntRequired(row['word_id'])),
                word: row['word'] as String,
                partOfSpeech: Value(row['part_of_speech'] as String?),
                partOfSpeechMark: Value(row['part_of_speech_mark'] as String?),
              ),
              mode: InsertMode.insertOrIgnore);
        }
      });
    }
    AppLogger.print('✓ words');
  }

  Future<void> _importDictionaries(Map<String, dynamic> tableData) async {
    final rows = tableData['rows'] as List;
    AppLogger.print('Importing ${rows.length} dictionaries...');
    const batchSize = 500;
    for (var i = 0; i < rows.length; i += batchSize) {
      _updateProgress(
          message: 'dictionary table 初期化中...',
          type: WebDBLoadingType.import,
          progress: (_currentRows / _totalRows));
      _currentRows += batchSize;
      final batch = rows.skip(i).take(batchSize).toList();
      await db.batch((b) {
        for (final row in batch) {
          if (row['dictionary_id'] == null ||
              row['word_id'] == null ||
              row['word'] == null) {
            continue;
          }
          b.insert(
              db.espJpnDictionaries,
              EspJpnDictionariesCompanion.insert(
                dictionaryId: Value(_toIntRequired(row['dictionary_id'])),
                wordId: _toIntRequired(row['word_id']),
                word: row['word'] as String,
                excf: Value(_toInt(row['excf'])),
                headword: Value(row['headword'] as String?),
                partOfSpeech: Value(row['part_of_speech'] as String?),
                partOfSpeechMark: Value(row['part_of_speech_mark'] as String?),
                content: Value(row['content'] as String?),
                origin: Value(row['origin'] as String?),
                htmlRaw: Value(row['html_raw'] as String?),
              ),
              mode: InsertMode.insertOrIgnore);
        }
      });
    }
    AppLogger.print('==========✓ dictionaries print');
    AppLogger.print('✓ dictionaries');
  }

  Future<void> _importExamples(Map<String, dynamic> tableData) async {
    final rows = tableData['rows'] as List;
    AppLogger.print('Importing ${rows.length} examples...');
    const batchSize = 500;
    for (var i = 0; i < rows.length; i += batchSize) {
      _updateProgress(
          message: 'example table 初期化中...',
          type: WebDBLoadingType.import,
          progress: (_currentRows / _totalRows));
      _currentRows += batchSize;
      final batch = rows.skip(i).take(batchSize).toList();
      await db.batch((b) {
        for (final row in batch) {
          if (row['example_id'] == null || row['example_no'] == null) continue;
          b.insert(
              db.espJpnExamples,
              EspJpnExamplesCompanion.insert(
                exampleId: Value(_toIntRequired(row['example_id'])),
                dictionaryId: Value(_toInt(row['dictionary_id'])),
                exampleNo: _toIntRequired(row['example_no']),
                espanolHtml: row['espanol_html'] as String? ?? '',
                japaneseText: row['japanese_text'] as String? ?? '',
                espanolText: row['espanol_text'] as String? ?? '',
              ),
              mode: InsertMode.insertOrIgnore);
        }
      });
    }
    AppLogger.print('✓ examples');
  }

  Future<void> _importIdioms(Map<String, dynamic> tableData) async {
    final rows = tableData['rows'] as List;
    AppLogger.print('Importing ${rows.length} idioms...');
    const batchSize = 500;
    for (var i = 0; i < rows.length; i += batchSize) {
      _updateProgress(
          message: 'idiom table 初期化中...',
          type: WebDBLoadingType.import,
          progress: (_currentRows / _totalRows));
      _currentRows += batchSize;
      final batch = rows.skip(i).take(batchSize).toList();
      await db.batch((b) {
        for (final row in batch) {
          if (row['idiom_id'] == null || row['idiom_no'] == null) continue;
          b.insert(
              db.espJpnIdioms,
              EspJpnIdiomsCompanion.insert(
                idiomId: Value(_toIntRequired(row['idiom_id'])),
                dictionaryId: Value(_toInt(row['dictionary_id'])),
                idiomNo: _toIntRequired(row['idiom_no']),
                idiom: row['idiom'] as String? ?? '',
                description: row['description'] as String? ?? '',
              ),
              mode: InsertMode.insertOrIgnore);
        }
      });
    }
    AppLogger.print('✓ idioms');
  }

  Future<void> _importSupplements(Map<String, dynamic> tableData) async {
    final rows = tableData['rows'] as List;
    AppLogger.print('Importing ${rows.length} supplements...');
    const batchSize = 500;
    for (var i = 0; i < rows.length; i += batchSize) {
      _updateProgress(
          message: 'supplement table 初期化中...',
          type: WebDBLoadingType.import,
          progress: (_currentRows / _totalRows));
      _currentRows += batchSize;
      final batch = rows.skip(i).take(batchSize).toList();
      await db.batch((b) {
        for (final row in batch) {
          if (row['supplement_id'] == null || row['supplement_no'] == null) {
            continue;
          }
          b.insert(
              db.espJpnSupplements,
              EspJpnSupplementsCompanion.insert(
                supplementId: Value(_toIntRequired(row['supplement_id'])),
                dictionaryId: Value(_toInt(row['dictionary_id'])),
                supplementNo: _toIntRequired(row['supplement_no']),
                content: row['content'] as String? ?? '',
                exampleId: Value(_toInt(row['example_id'])),
              ),
              mode: InsertMode.insertOrIgnore);
        }
      });
    }
    AppLogger.print('✓ supplements');
  }

  Future<void> _importConjugations(Map<String, dynamic> tableData) async {
    final rows = tableData['rows'] as List;
    AppLogger.print('Importing ${rows.length} conjugations (complex table)...');
    const batchSize = 100;
    for (var i = 0; i < rows.length; i += batchSize) {
      _updateProgress(
          message: 'conjugation table 初期化中...',
          type: WebDBLoadingType.import,
          progress: (_currentRows / _totalRows));
      _currentRows += batchSize;
      final batch = rows.skip(i).take(batchSize).toList();
      await db.batch((b) {
        for (final row in batch) {
          if (row['word'] == null) continue;
          b.insert(
              db.espConjugations,
              EspConjugationsCompanion.insert(
                wordId: Value(_toIntRequired(row['word_id'])),
                word: row['word'] as String,
                meaning: Value(row['meaning'] as String?),
                presentParticiple: Value(row['present_participle'] as String?),
                pastParticiple: Value(row['past_participle'] as String?),
                indicativePresentYo:
                    Value(row['indicative_present_yo'] as String?),
                indicativePresentTu:
                    Value(row['indicative_present_tu'] as String?),
                indicativePresentEl:
                    Value(row['indicative_present_el'] as String?),
                indicativePresentNosotros:
                    Value(row['indicative_present_nosotros'] as String?),
                indicativePresentVosotros:
                    Value(row['indicative_present_vosotros'] as String?),
                indicativePresentEllos:
                    Value(row['indicative_present_ellos'] as String?),
                indicativePreteriteYo:
                    Value(row['indicative_preterite_yo'] as String?),
                indicativePreteriteTu:
                    Value(row['indicative_preterite_tu'] as String?),
                indicativePreteriteEl:
                    Value(row['indicative_preterite_el'] as String?),
                indicativePreteriteNosotros:
                    Value(row['indicative_preterite_nosotros'] as String?),
                indicativePreteriteVosotros:
                    Value(row['indicative_preterite_vosotros'] as String?),
                indicativePreteriteEllos:
                    Value(row['indicative_preterite_ellos'] as String?),
                indicativeImperfectYo:
                    Value(row['indicative_imperfect_yo'] as String?),
                indicativeImperfectTu:
                    Value(row['indicative_imperfect_tu'] as String?),
                indicativeImperfectEl:
                    Value(row['indicative_imperfect_el'] as String?),
                indicativeImperfectNosotros:
                    Value(row['indicative_imperfect_nosotros'] as String?),
                indicativeImperfectVosotros:
                    Value(row['indicative_imperfect_vosotros'] as String?),
                indicativeImperfectEllos:
                    Value(row['indicative_imperfect_ellos'] as String?),
                indicativeFutureYo:
                    Value(row['indicative_future_yo'] as String?),
                indicativeFutureTu:
                    Value(row['indicative_future_tu'] as String?),
                indicativeFutureEl:
                    Value(row['indicative_future_el'] as String?),
                indicativeFutureNosotros:
                    Value(row['indicative_future_nosotros'] as String?),
                indicativeFutureVosotros:
                    Value(row['indicative_future_vosotros'] as String?),
                indicativeFutureEllos:
                    Value(row['indicative_future_ellos'] as String?),
                indicativeConditionalYo:
                    Value(row['indicative_conditional_yo'] as String?),
                indicativeConditionalTu:
                    Value(row['indicative_conditional_tu'] as String?),
                indicativeConditionalEl:
                    Value(row['indicative_conditional_el'] as String?),
                indicativeConditionalNosotros:
                    Value(row['indicative_conditional_nosotros'] as String?),
                indicativeConditionalVosotros:
                    Value(row['indicative_conditional_vosotros'] as String?),
                indicativeConditionalEllos:
                    Value(row['indicative_conditional_ellos'] as String?),
                imperativeTu: Value(row['imperative_tu'] as String?),
                imperativeEl: Value(row['imperative_el'] as String?),
                imperativeNosotros:
                    Value(row['imperative_nosotros'] as String?),
                imperativeVosotros:
                    Value(row['imperative_vosotros'] as String?),
                imperativeEllos: Value(row['imperative_ellos'] as String?),
                subjunctivePresentYo:
                    Value(row['subjunctive_present_yo'] as String?),
                subjunctivePresentTu:
                    Value(row['subjunctive_present_tu'] as String?),
                subjunctivePresentEl:
                    Value(row['subjunctive_present_el'] as String?),
                subjunctivePresentNosotros:
                    Value(row['subjunctive_present_nosotros'] as String?),
                subjunctivePresentVosotros:
                    Value(row['subjunctive_present_vosotros'] as String?),
                subjunctivePresentEllos:
                    Value(row['subjunctive_present_ellos'] as String?),
                subjunctivePastYo: Value(row['subjunctive_past_yo'] as String?),
                subjunctivePastTu: Value(row['subjunctive_past_tu'] as String?),
                subjunctivePastEl: Value(row['subjunctive_past_el'] as String?),
                subjunctivePastNosotros:
                    Value(row['subjunctive_past_nosotros'] as String?),
                subjunctivePastVosotros:
                    Value(row['subjunctive_past_vosotros'] as String?),
                subjunctivePastEllos:
                    Value(row['subjunctive_past_ellos'] as String?),
              ),
              mode: InsertMode.insertOrIgnore);
        }
      });
    }
    AppLogger.print('✓ conjugations');
  }

  Future<void> _importPartOfSpeechLists(Map<String, dynamic> tableData) async {
    final rows = tableData['rows'] as List;
    AppLogger.print('Importing ${rows.length} part_of_speech_lists...');
    const batchSize = 1000;
    for (var i = 0; i < rows.length; i += batchSize) {
      _updateProgress(
          message: 'part_of_speech_lists table 初期化中...',
          type: WebDBLoadingType.import,
          progress: (_currentRows / _totalRows));
      _currentRows += batchSize;
      final batch = rows.skip(i).take(batchSize).toList();
      await db.batch((b) {
        for (final row in batch) {
          if (row['part_of_speech_id'] == null ||
              row['word_id'] == null ||
              row['part_of_speech'] == null) {
            continue;
          }
          b.insert(
              db.partOfSpeechLists,
              PartOfSpeechListsCompanion.insert(
                partOfSpeechId: Value(_toIntRequired(row['part_of_speech_id'])),
                wordId: _toIntRequired(row['word_id']),
                partOfSpeech: row['part_of_speech'] as String,
              ),
              mode: InsertMode.insertOrIgnore);
        }
      });
    }
    AppLogger.print('✓ part_of_speech_lists');
  }

  Future<void> _importJpnEspWords(Map<String, dynamic> tableData) async {
    final rows = tableData['rows'] as List;
    AppLogger.print('Importing ${rows.length} jpn_esp_words...');
    const batchSize = 500;
    for (var i = 0; i < rows.length; i += batchSize) {
      _updateProgress(
          message: 'jpn_esp_words table 初期化中...',
          type: WebDBLoadingType.import,
          progress: (_currentRows / _totalRows));
      _currentRows += batchSize;
      final batch = rows.skip(i).take(batchSize).toList();
      await db.batch((b) {
        for (final row in batch) {
          if (row['jpn_esp_word_id'] == null || row['word'] == null) continue;
          b.insert(
              db.jpnEspWords,
              JpnEspWordsCompanion.insert(
                wordId: Value(_toIntRequired(row['jpn_esp_word_id'])),
                word: row['word'] as String,
              ),
              mode: InsertMode.insertOrIgnore);
        }
      });
    }
    AppLogger.print('✓ jpn_esp_words');
  }

  Future<void> _importJpnEspDictionaries(Map<String, dynamic> tableData) async {
    final rows = tableData['rows'] as List;
    AppLogger.print('Importing ${rows.length} jpn_esp_dictionaries...');
    const batchSize = 500;
    for (var i = 0; i < rows.length; i += batchSize) {
      _updateProgress(
          message: 'jpn_esp_dictionaries table 初期化中...',
          type: WebDBLoadingType.import,
          progress: (_currentRows / _totalRows));
      _currentRows += batchSize;
      final batch = rows.skip(i).take(batchSize).toList();
      await db.batch((b) {
        for (final row in batch) {
          if (row['jpn_esp_dictionary_id'] == null ||
              row['jpn_esp_word_id'] == null ||
              row['word'] == null) {
            continue;
          }
          b.insert(
              db.jpnEspDictionaries,
              JpnEspDictionariesCompanion.insert(
                dictionaryId:
                    Value(_toIntRequired(row['jpn_esp_dictionary_id'])),
                wordId: _toIntRequired(row['jpn_esp_word_id']),
                word: row['word'] as String,
                excf: _toIntRequired(row['excf']),
                headword: row['headword'] as String,
                content: row['content'] as String,
                htmlRaw: row['html_raw'] as String,
              ),
              mode: InsertMode.insertOrIgnore);
        }
      });
    }
    AppLogger.print('✓ jpn_esp_dictionaries');
  }

  Future<void> _importJpnEspExamples(Map<String, dynamic> tableData) async {
    final rows = tableData['rows'] as List;
    AppLogger.print('Importing ${rows.length} jpn_esp_examples...');
    const batchSize = 500;
    for (var i = 0; i < rows.length; i += batchSize) {
      _updateProgress(
          message: 'jpn_esp_examples table 初期化中...',
          type: WebDBLoadingType.import,
          progress: (_currentRows / _totalRows));
      _currentRows += batchSize;
      final batch = rows.skip(i).take(batchSize).toList();
      await db.batch((b) {
        for (final row in batch) {
          if (row['jpn_esp_example_id'] == null ||
              row['example_no'] == null ||
              row['jpn_esp_dictionary_id'] == null) {
            continue;
          }
          b.insert(
              db.jpnEspExamples,
              JpnEspExamplesCompanion.insert(
                exampleId: Value(_toIntRequired(row['jpn_esp_example_id'])),
                dictionaryId: _toIntRequired(row['jpn_esp_dictionary_id']),
                // wordId: _toIntRequired(row['word_id']),
                exampleNo: _toIntRequired(row['example_no']),
                japaneseText: row['japanese_text'] as String? ?? '',
                espanolHtml: row['espanol_html'] as String? ?? '',
                espanolText: row['espanol_text'] as String? ?? '',
              ),
              mode: InsertMode.insertOrIgnore);
        }
      });
    }
    AppLogger.print('✓ jpn_esp_examples');
  }

  Future<void> _importRankings(Map<String, dynamic> tableData) async {
    final rows = tableData['rows'] as List;
    AppLogger.print('Importing ${rows.length} rankings...');
    const batchSize = 500;
    for (var i = 0; i < rows.length; i += batchSize) {
      _updateProgress(
          message: 'rankings table 初期化中...',
          type: WebDBLoadingType.import,
          progress: (_currentRows / _totalRows));
      _currentRows += batchSize;
      final batch = rows.skip(i).take(batchSize).toList();
      await db.batch((b) {
        for (final row in batch) {
          if (row['ranking_id'] == null || row['ranking_no'] == null) {
            AppLogger.print(
                '~~~~~~skip ranking ${row['word'] ?? "unknown"} rankings...');
            continue;
          }
          b.insert(
              db.rankings,
              RankingsCompanion.insert(
                rankingId: Value(_toIntRequired(row['ranking_id'])),
                rankingNo: _toIntRequired(row['ranking_no']),
                word: Value(row['word'] as String?),
                wordOrigin: Value(row['word_origin'] as String?),
                hasConj: Value(_toInt(row['has_conj'])),
                wordId: Value(_toInt(row['word_id'])),
              ),
              mode: InsertMode.insertOrIgnore);
        }
      });
    }
    AppLogger.print('✓ rankings');
  }

  Future<void> _importEsEnConjugacions(Map<String, dynamic> tableData) async {
    final rows = tableData['rows'] as List;
    AppLogger.print('Importing ${rows.length} es_en_conjugacions...');
    const batchSize = 500;
    for (var i = 0; i < rows.length; i += batchSize) {
      _updateProgress(
          message: 'es_en_conjugacions table 初期化中...',
          type: WebDBLoadingType.import,
          progress: (_currentRows / _totalRows));
      _currentRows += batchSize;
      final batch = rows.skip(i).take(batchSize).toList();
      await db.batch((b) {
        for (final row in batch) {
          if (row['word_id'] == null) continue;
          b.insert(
              db.esEnConjugacions,
              EsEnConjugacionsCompanion.insert(
                wordId: Value(_toIntRequired(row['word_id'])),
                word: Value(row['word'] as String?),
                english: Value(row['english'] as String?),
                present3rd: Value(row['present_3rd'] as String?),
                presentP: Value(row['present_p'] as String?),
                past: Value(row['past'] as String?),
                pastP: Value(row['past_p'] as String?),
              ),
              mode: InsertMode.insertOrIgnore);
        }
      });
    }
    AppLogger.print('✓ es_en_conjugacions');
  }

  Future<void> _importEspJpnWordStatus(Map<String, dynamic> tableData) async {
    final rows = tableData['rows'] as List;
    AppLogger.print('Importing ${rows.length} esp_jpn_word_status...');
    const batchSize = 500;
    for (var i = 0; i < rows.length; i += batchSize) {
      _updateProgress(
          message: 'esp_jpn_word_status table 初期化中...',
          type: WebDBLoadingType.import,
          progress: (_currentRows / _totalRows));
      _currentRows += batchSize;
      final batch = rows.skip(i).take(batchSize).toList();
      await db.batch((b) {
        for (final row in batch) {
          if (row['word_id'] == null || row['edit_at'] == null) continue;
          b.insert(
              db.espJpnWordStatus,
              EspJpnWordStatusCompanion.insert(
                wordId: _toIntRequired(row['word_id']),
                isLearned: Value(_toIntRequired(row['is_learned'])),
                isBookmarked: Value(_toIntRequired(row['is_bookmarked'])),
                hasNote: Value(_toIntRequired(row['has_note'])),
                editAt: row['edit_at'] as String,
              ),
              mode: InsertMode.insertOrIgnore);
        }
      });
    }
    AppLogger.print('✓ esp_jpn_word_status');
  }

  Future<void> _importMyWords(Map<String, dynamic> tableData) async {
    final rows = tableData['rows'] as List;
    AppLogger.print('Importing ${rows.length} my_words...');
    const batchSize = 500;
    for (var i = 0; i < rows.length; i += batchSize) {
      _updateProgress(
          message: 'my_words table 初期化中...',
          type: WebDBLoadingType.import,
          progress: (_currentRows / _totalRows));
      _currentRows += batchSize;
      final batch = rows.skip(i).take(batchSize).toList();
      await db.batch((b) {
        for (final row in batch) {
          if (row['my_word_id'] == null ||
              row['word'] == null ||
              row['edit_at'] == null) {
            continue;
          }
          b.insert(
              db.myWords,
              MyWordsCompanion.insert(
                myWordId: _toStringRequired(row['my_word_id']),
                contents: Value(row['contents'] as String?),
                word: row['word'] as String,
                editAt: _toStringRequired(row['edit_at']),
              ),
              mode: InsertMode.insertOrIgnore);
        }
      });
    }
    AppLogger.print('✓ my_words');
  }

  Future<void> _importMyWordStatus(Map<String, dynamic> tableData) async {
    final rows = tableData['rows'] as List;
    AppLogger.print('Importing ${rows.length} my_word_status...');
    const batchSize = 500;
    for (var i = 0; i < rows.length; i += batchSize) {
      _updateProgress(
          message: 'my_word_status table 初期化中...',
          type: WebDBLoadingType.import,
          progress: (_currentRows / _totalRows));
      _currentRows += batchSize;
      final batch = rows.skip(i).take(batchSize).toList();
      await db.batch((b) {
        for (final row in batch) {
          if (row['my_word_id'] == null ||
              row['word'] == null ||
              row['edit_at'] == null) {
            continue;
          }
          b.insert(
              db.myWordStatus,
              MyWordStatusCompanion.insert(
                myWordId: _toStringRequired(row['my_word_id']),
                isLearned: Value(_toIntRequired(row['is_learned'])),
                isBookmarked: Value(_toIntRequired(row['is_bookmarked'])),
                hasNote: Value(_toIntRequired(row['has_note'])),
                editAt: _toStringRequired(row['edit_at']),
              ),
              mode: InsertMode.insertOrIgnore);
        }
      });
    }
    AppLogger.print('✓ my_word_status');
  }

  Future<void> _importJpnEspWordStatus(Map<String, dynamic> tableData) async {
    final rows = tableData['rows'] as List;
    AppLogger.print('Importing ${rows.length} jpn_esp_word_status...');
    const batchSize = 500;
    for (var i = 0; i < rows.length; i += batchSize) {
      _updateProgress(
          message: 'jpn_esp_word_status table 初期化中...',
          type: WebDBLoadingType.import,
          progress: (_currentRows / _totalRows));
      _currentRows += batchSize;
      final batch = rows.skip(i).take(batchSize).toList();
      await db.batch((b) {
        for (final row in batch) {
          if (row['jpn_esp_word_id'] == null || row['edit_at'] == null) {
            continue;
          }
          b.insert(
              db.jpnEspWordStatus,
              JpnEspWordStatusCompanion.insert(
                wordId: _toIntRequired(row['jpn_esp_word_id']),
                isLearned: Value(_toIntRequired(row['is_learned'])),
                isBookmarked: Value(_toIntRequired(row['is_bookmarked'])),
                hasNote: Value(_toIntRequired(row['has_note'])),
                editAt: row['edit_at'] as String,
              ),
              mode: InsertMode.insertOrIgnore);
        }
      });
    }
    AppLogger.print('✓ jpn_esp_word_status');
  }
}
