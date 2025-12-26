/// Web用データベースシーディングヘルパー
/// Gzip圧縮JSONからDriftデータベースにデータをインポート
/// 
/// 注意: このファイルはWeb環境専用です
/// データベーススキーマと完全に同期している必要があります

import 'dart:convert';
import 'dart:developer';
import 'package:archive/archive.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:drift/drift.dart';
import 'package:my_dic/core/infrastructure/database/drift/database_provider.dart';

class WebDatabaseSeeder {
  final DatabaseProvider db;

  WebDatabaseSeeder(this.db);

  /// Web環境でデータベースをシードする
  Future<void> seedFromJson() async {
    log('WebDatabaseSeeder: Starting database seeding from compressed JSON...');
    log('⚠️ This is first-time setup and may take 2-5 minutes');

    try {
      await _seedKotobankData();
      await _seedEsEnConjugacions();
      log('WebDatabaseSeeder: ✓ Seeding completed successfully');
    } catch (e, stackTrace) {
      log('WebDatabaseSeeder: ✗ Error - $e');
      log('StackTrace: $stackTrace');
      rethrow;
    }
  }

  Future<Map<String, dynamic>> _loadCompressedJson(String assetPath) async {
    log('Loading: $assetPath');
    final byteData = await rootBundle.load(assetPath);
    final compressed = byteData.buffer.asUint8List();
    log('  Compressed size: ${(compressed.length / 1024 / 1024).toStringAsFixed(2)} MB');
    
    final decompressed = GZipDecoder().decodeBytes(compressed);
    log('  Decompressed: ${(decompressed.length / 1024 / 1024).toStringAsFixed(2)} MB');
    
    final jsonString = utf8.decode(decompressed);
    return jsonDecode(jsonString) as Map<String, dynamic>;
  }

  Future<void> _seedKotobankData() async {
    final data = await _loadCompressedJson('assets/data/kotobank.json.gz');
    final tables = data['tables'] as Map<String, dynamic>;

    // Import in order respecting foreign key dependencies
    if (tables.containsKey('words')) await _importWords(tables['words']);
    if (tables.containsKey('dictionaries')) await _importDictionaries(tables['dictionaries']);
    if (tables.containsKey('part_of_speech_lists')) await _importPartOfSpeechLists(tables['part_of_speech_lists']);
    if (tables.containsKey('examples')) await _importExamples(tables['examples']);
    if (tables.containsKey('idioms')) await _importIdioms(tables['idioms']);
    if (tables.containsKey('supplements')) await _importSupplements(tables['supplements']);
    if (tables.containsKey('conjugations')) await _importConjugations(tables['conjugations']);
    if (tables.containsKey('jpn_esp_words')) await _importJpnEspWords(tables['jpn_esp_words']);
    if (tables.containsKey('jpn_esp_dictionaries')) await _importJpnEspDictionaries(tables['jpn_esp_dictionaries']);
    if (tables.containsKey('jpn_esp_examples')) await _importJpnEspExamples(tables['jpn_esp_examples']);
    if (tables.containsKey('rankings')) await _importRankings(tables['rankings']);
  }

  Future<void> _seedEsEnConjugacions() async {
    final data = await _loadCompressedJson('assets/data/es_en_conjugacions.json.gz');
    final tables = data['tables'] as Map<String, dynamic>;
    if (tables.containsKey('es_en_conjugacions')) {
      await _importEsEnConjugacions(tables['es_en_conjugacions']);
    }
  }

  // Simplified imports - Web環境では詳細なログは不要
  Future<void> _importWords(Map<String, dynamic> tableData) async {
    final rows = tableData['rows'] as List;
    log('Importing ${rows.length} words...');
    const batchSize = 500;
    for (var i = 0; i < rows.length; i += batchSize) {
      final batch = rows.skip(i).take(batchSize).toList();
      await db.batch((b) {
        for (final row in batch) {
          // Skip rows that don't have required fields
          if (row['word_id'] == null || row['word'] == null) continue;
          b.insert(db.espJpnWords, EspJpnWordsCompanion.insert(
            wordId: Value(row['word_id'] as int),
            word: row['word'] as String,
            partOfSpeech: Value(row['part_of_speech'] as String?),
            partOfSpeechMark: Value(row['part_of_speech_mark'] as String?),
          ), mode: InsertMode.insertOrIgnore);
        }
      });
    }
    log('✓ words');
  }

  Future<void> _importDictionaries(Map<String, dynamic> tableData) async {
    final rows = tableData['rows'] as List;
    log('Importing ${rows.length} dictionaries...');
    const batchSize = 500;
    for (var i = 0; i < rows.length; i += batchSize) {
      final batch = rows.skip(i).take(batchSize).toList();
      await db.batch((b) {
        for (final row in batch) {
          if (row['dictionary_id'] == null || row['word_id'] == null || row['word'] == null) continue;
          b.insert(db.espJpnDictionaries, EspJpnDictionariesCompanion.insert(
            dictionaryId: Value(row['dictionary_id'] as int),
            wordId: row['word_id'] as int,
            word: row['word'] as String,
            excf: Value(row['excf'] as int?),
            headword: Value(row['headword'] as String?),
            partOfSpeech: Value(row['part_of_speech'] as String?),
            partOfSpeechMark: Value(row['part_of_speech_mark'] as String?),
            content: Value(row['content'] as String?),
            origin: Value(row['origin'] as String?),
            htmlRaw: Value(row['html_raw'] as String?),
          ), mode: InsertMode.insertOrIgnore);
        }
      });
    }
    log('✓ dictionaries');
  }

  Future<void> _importExamples(Map<String, dynamic> tableData) async {
    final rows = tableData['rows'] as List;
    log('Importing ${rows.length} examples...');
    const batchSize = 500;
    for (var i = 0; i < rows.length; i += batchSize) {
      final batch = rows.skip(i).take(batchSize).toList();
      await db.batch((b) {
        for (final row in batch) {
          if (row['example_id'] == null || row['example_no'] == null) continue;
          b.insert(db.espJpnExamples, EspJpnExamplesCompanion.insert(
            exampleId: Value(row['example_id'] as int),
            dictionaryId: Value(row['dictionary_id'] as int?),
            exampleNo: row['example_no'] as int,
            espanolHtml: row['espanol_html'] as String? ?? '',
            japaneseText: row['japanese_text'] as String? ?? '',
            espanolText: row['espanol_text'] as String? ?? '',
          ), mode: InsertMode.insertOrIgnore);
        }
      });
    }
    log('✓ examples');
  }

  Future<void> _importIdioms(Map<String, dynamic> tableData) async {
    final rows = tableData['rows'] as List;
    log('Importing ${rows.length} idioms...');
    const batchSize = 500;
    for (var i = 0; i < rows.length; i += batchSize) {
      final batch = rows.skip(i).take(batchSize).toList();
      await db.batch((b) {
        for (final row in batch) {
          if (row['idiom_id'] == null || row['idiom_no'] == null) continue;
          b.insert(db.espJpnIdioms, EspJpnIdiomsCompanion.insert(
            idiomId: Value(row['idiom_id'] as int),
            dictionaryId: Value(row['dictionary_id'] as int?),
            idiomNo: row['idiom_no'] as int,
            idiom: row['idiom'] as String? ?? '',
            description: row['description'] as String? ?? '',
          ), mode: InsertMode.insertOrIgnore);
        }
      });
    }
    log('✓ idioms');
  }

  Future<void> _importSupplements(Map<String, dynamic> tableData) async {
    final rows = tableData['rows'] as List;
    log('Importing ${rows.length} supplements...');
    const batchSize = 500;
    for (var i = 0; i < rows.length; i += batchSize) {
      final batch = rows.skip(i).take(batchSize).toList();
      await db.batch((b) {
        for (final row in batch) {
          if (row['supplement_id'] == null || row['supplement_no'] == null) continue;
          b.insert(db.espJpnSupplements, EspJpnSupplementsCompanion.insert(
            supplementId: Value(row['supplement_id'] as int),
            dictionaryId: Value(row['dictionary_id'] as int?),
            supplementNo: row['supplement_no'] as int,
            content: row['content'] as String? ?? '',
            exampleId: Value(row['example_id'] as int?),
          ), mode: InsertMode.insertOrIgnore);
        }
      });
    }
    log('✓ supplements');
  }

  Future<void> _importConjugations(Map<String, dynamic> tableData) async {
    final rows = tableData['rows'] as List;
    log('Importing ${rows.length} conjugations (complex table)...');
    const batchSize = 100;
    for (var i = 0; i < rows.length; i += batchSize) {
      final batch = rows.skip(i).take(batchSize).toList();
      await db.batch((b) {
        for (final row in batch) {
          if (row['word'] == null) continue;
          b.insert(db.espConjugations, EspConjugationsCompanion.insert(
            word: row['word'] as String,
            meaning: Value(row['meaning'] as String?),
            presentParticiple: Value(row['present_participle'] as String?),
            pastParticiple: Value(row['past_participle'] as String?),
            indicativePresentYo: Value(row['indicative_present_yo'] as String?),
            indicativePresentTu: Value(row['indicative_present_tu'] as String?),
            indicativePresentEl: Value(row['indicative_present_el'] as String?),
            indicativePresentNosotros: Value(row['indicative_present_nosotros'] as String?),
            indicativePresentVosotros: Value(row['indicative_present_vosotros'] as String?),
            indicativePresentEllos: Value(row['indicative_present_ellos'] as String?),
            indicativePreteriteYo: Value(row['indicative_preterite_yo'] as String?),
            indicativePreteriteTu: Value(row['indicative_preterite_tu'] as String?),
            indicativePreteriteEl: Value(row['indicative_preterite_el'] as String?),
            indicativePreteriteNosotros: Value(row['indicative_preterite_nosotros'] as String?),
            indicativePreteriteVosotros: Value(row['indicative_preterite_vosotros'] as String?),
            indicativePreteriteEllos: Value(row['indicative_preterite_ellos'] as String?),
            indicativeImperfectYo: Value(row['indicative_imperfect_yo'] as String?),
            indicativeImperfectTu: Value(row['indicative_imperfect_tu'] as String?),
            indicativeImperfectEl: Value(row['indicative_imperfect_el'] as String?),
            indicativeImperfectNosotros: Value(row['indicative_imperfect_nosotros'] as String?),
            indicativeImperfectVosotros: Value(row['indicative_imperfect_vosotros'] as String?),
            indicativeImperfectEllos: Value(row['indicative_imperfect_ellos'] as String?),
            indicativeFutureYo: Value(row['indicative_future_yo'] as String?),
            indicativeFutureTu: Value(row['indicative_future_tu'] as String?),
            indicativeFutureEl: Value(row['indicative_future_el'] as String?),
            indicativeFutureNosotros: Value(row['indicative_future_nosotros'] as String?),
            indicativeFutureVosotros: Value(row['indicative_future_vosotros'] as String?),
            indicativeFutureEllos: Value(row['indicative_future_ellos'] as String?),
            indicativeConditionalYo: Value(row['indicative_conditional_yo'] as String?),
            indicativeConditionalTu: Value(row['indicative_conditional_tu'] as String?),
            indicativeConditionalEl: Value(row['indicative_conditional_el'] as String?),
            indicativeConditionalNosotros: Value(row['indicative_conditional_nosotros'] as String?),
            indicativeConditionalVosotros: Value(row['indicative_conditional_vosotros'] as String?),
            indicativeConditionalEllos: Value(row['indicative_conditional_ellos'] as String?),
            imperativeTu: Value(row['imperative_tu'] as String?),
            imperativeEl: Value(row['imperative_el'] as String?),
            imperativeNosotros: Value(row['imperative_nosotros'] as String?),
            imperativeVosotros: Value(row['imperative_vosotros'] as String?),
            imperativeEllos: Value(row['imperative_ellos'] as String?),
            subjunctivePresentYo: Value(row['subjunctive_present_yo'] as String?),
            subjunctivePresentTu: Value(row['subjunctive_present_tu'] as String?),
            subjunctivePresentEl: Value(row['subjunctive_present_el'] as String?),
            subjunctivePresentNosotros: Value(row['subjunctive_present_nosotros'] as String?),
            subjunctivePresentVosotros: Value(row['subjunctive_present_vosotros'] as String?),
            subjunctivePresentEllos: Value(row['subjunctive_present_ellos'] as String?),
            subjunctivePastYo: Value(row['subjunctive_past_yo'] as String?),
            subjunctivePastTu: Value(row['subjunctive_past_tu'] as String?),
            subjunctivePastEl: Value(row['subjunctive_past_el'] as String?),
            subjunctivePastNosotros: Value(row['subjunctive_past_nosotros'] as String?),
            subjunctivePastVosotros: Value(row['subjunctive_past_vosotros'] as String?),
            subjunctivePastEllos: Value(row['subjunctive_past_ellos'] as String?),
          ), mode: InsertMode.insertOrIgnore);
        }
      });
    }
    log('✓ conjugations');
  }

  Future<void> _importPartOfSpeechLists(Map<String, dynamic> tableData) async {
    final rows = tableData['rows'] as List;
    log('Importing ${rows.length} part_of_speech_lists...');
    const batchSize = 1000;
    for (var i = 0; i < rows.length; i += batchSize) {
      final batch = rows.skip(i).take(batchSize).toList();
      await db.batch((b) {
        for (final row in batch) {
          if (row['part_of_speech_id'] == null || row['word_id'] == null || row['part_of_speech'] == null) continue;
          b.insert(db.partOfSpeechLists, PartOfSpeechListsCompanion.insert(
            partOfSpeechId: Value(row['part_of_speech_id'] as int),
            wordId: row['word_id'] as int,
            partOfSpeech: row['part_of_speech'] as String,
          ), mode: InsertMode.insertOrIgnore);
        }
      });
    }
    log('✓ part_of_speech_lists');
  }

  Future<void> _importJpnEspWords(Map<String, dynamic> tableData) async {
    final rows = tableData['rows'] as List;
    log('Importing ${rows.length} jpn_esp_words...');
    const batchSize = 500;
    for (var i = 0; i < rows.length; i += batchSize) {
      final batch = rows.skip(i).take(batchSize).toList();
      await db.batch((b) {
        for (final row in batch) {
          if (row['word_id'] == null || row['word'] == null) continue;
          b.insert(db.jpnEspWords, JpnEspWordsCompanion.insert(
            wordId: Value(row['word_id'] as int),
            word: row['word'] as String,
          ), mode: InsertMode.insertOrIgnore);
        }
      });
    }
    log('✓ jpn_esp_words');
  }

  Future<void> _importJpnEspDictionaries(Map<String, dynamic> tableData) async {
    final rows = tableData['rows'] as List;
    log('Importing ${rows.length} jpn_esp_dictionaries...');
    const batchSize = 500;
    for (var i = 0; i < rows.length; i += batchSize) {
      final batch = rows.skip(i).take(batchSize).toList();
      await db.batch((b) {
        for (final row in batch) {
          if (row['dictionary_id'] == null || row['word_id'] == null || row['word'] == null || row['excf'] == null || row['headword'] == null || row['content'] == null || row['html_raw'] == null) continue;
          b.insert(db.jpnEspDictionaries, JpnEspDictionariesCompanion.insert(
            dictionaryId: Value(row['dictionary_id'] as int),
            wordId: row['word_id'] as int,
            word: row['word'] as String,
            excf: row['excf'] as int,
            headword: row['headword'] as String,
            content: row['content'] as String,
            htmlRaw: row['html_raw'] as String,
          ), mode: InsertMode.insertOrIgnore);
        }
      });
    }
    log('✓ jpn_esp_dictionaries');
  }

  Future<void> _importJpnEspExamples(Map<String, dynamic> tableData) async {
    final rows = tableData['rows'] as List;
    log('Importing ${rows.length} jpn_esp_examples...');
    const batchSize = 500;
    for (var i = 0; i < rows.length; i += batchSize) {
      final batch = rows.skip(i).take(batchSize).toList();
      await db.batch((b) {
        for (final row in batch) {
          if (row['example_id'] == null || row['example_no'] == null || row['dictionary_id'] == null || row['word_id'] == null || row['japanese_text'] == null || row['espanol_html'] == null || row['espanol_text'] == null) continue;
          b.insert(db.jpnEspExamples, JpnEspExamplesCompanion.insert(
            exampleId: Value(row['example_id'] as int),
            dictionaryId: row['dictionary_id'] as int,
            wordId: row['word_id'] as int,
            exampleNo: row['example_no'] as int,
            japaneseText: row['japanese_text'] as String,
            espanolHtml: row['espanol_html'] as String,
            espanolText: row['espanol_text'] as String,
          ), mode: InsertMode.insertOrIgnore);
        }
      });
    }
    log('✓ jpn_esp_examples');
  }

  Future<void> _importRankings(Map<String, dynamic> tableData) async {
    final rows = tableData['rows'] as List;
    log('Importing ${rows.length} rankings...');
    const batchSize = 500;
    for (var i = 0; i < rows.length; i += batchSize) {
      final batch = rows.skip(i).take(batchSize).toList();
      await db.batch((b) {
        for (final row in batch) {
          if (row['ranking_id'] == null || row['ranking_no'] == null) continue;
          b.insert(db.rankings, RankingsCompanion.insert(
            rankingId: Value(row['ranking_id'] as int),
            rankingNo: row['ranking_no'] as int,
            word: Value(row['word'] as String?),
            wordOrigin: Value(row['word_origin'] as String?),
            hasConj: Value(row['has_conj'] as int?),
            wordId: Value(row['word_id'] as int?),
          ), mode: InsertMode.insertOrIgnore);
        }
      });
    }
    log('✓ rankings');
  }

  Future<void> _importEsEnConjugacions(Map<String, dynamic> tableData) async {
    final rows = tableData['rows'] as List;
    log('Importing ${rows.length} es_en_conjugacions...');
    const batchSize = 500;
    for (var i = 0; i < rows.length; i += batchSize) {
      final batch = rows.skip(i).take(batchSize).toList();
      await db.batch((b) {
        for (final row in batch) {
          if (row['word_id'] == null) continue;
          b.insert(db.esEnConjugacions, EsEnConjugacionsCompanion.insert(
            wordId: Value(row['word_id'] as int),
            word: Value(row['word'] as String?),
            english: Value(row['english'] as String?),
            present3rd: Value(row['present_3rd'] as String?),
            presentP: Value(row['present_p'] as String?),
            past: Value(row['past'] as String?),
            pastP: Value(row['past_p'] as String?),
          ), mode: InsertMode.insertOrIgnore);
        }
      });
    }
    log('✓ es_en_conjugacions');
  }
}
