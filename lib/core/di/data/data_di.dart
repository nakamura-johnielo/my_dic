import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:my_dic/features/catalog/internal/infrastructure/drift/dao/esp_jpn/conjugation_dao.dart';
import 'package:my_dic/features/catalog/internal/infrastructure/drift/dao/esp_jpn/dictionary_dao.dart';
import 'package:my_dic/core/infrastructure/database/drift/daos/es_en_conjugacion_dao.dart';
import 'package:my_dic/features/catalog/internal/infrastructure/drift/dao/esp_jpn/example_dao.dart';
import 'package:my_dic/features/catalog/internal/infrastructure/drift/dao/esp_jpn/idiom_dao.dart';
import 'package:my_dic/features/catalog/internal/infrastructure/drift/dao/jpn_esp/jpn_esp_dictionary_dao.dart';
import 'package:my_dic/features/catalog/internal/infrastructure/drift/dao/jpn_esp/jpn_esp_example_dao.dart';
import 'package:my_dic/features/catalog/internal/infrastructure/drift/dao/jpn_esp/jpn_esp_word_dao.dart';
import 'package:my_dic/features/catalog/internal/infrastructure/drift/dao/esp_jpn/supplement_dao.dart';
import 'package:my_dic/features/catalog/internal/infrastructure/drift/dao/esp_jpn/esp_jpn_word_dao.dart';
import 'package:my_dic/core/infrastructure/database/drift/database_provider.dart';

import 'package:my_dic/features/catalog/internal/infrastructure/drift/dao/esp_jpn/part_of_speech_list_dao.dart';

final databaseProvider = Provider<DatabaseProvider>((ref) {
  final database = DatabaseProvider();
  ref.onDispose(() {
    unawaited(database.close());
  });
  return database;
});

// --dictionary
final dictionaryDaoProvider = Provider<EspjpnDictionaryDao>((ref) {
  return EspjpnDictionaryDao(ref.read(databaseProvider));
});

final exampleDaoProvider = Provider<EspJpnExampleDao>((ref) {
  return EspJpnExampleDao(ref.read(databaseProvider));
});

final idiomDaoProvider = Provider<EspJpnIdiomDao>((ref) {
  return EspJpnIdiomDao(ref.read(databaseProvider));
});

final supplementDaoProvider = Provider<EspJpnSupplementDao>((ref) {
  return EspJpnSupplementDao(ref.read(databaseProvider));
});

final partOfSpeechListDaoProvider = Provider<PartOfSpeechListDao>((ref) {
  return PartOfSpeechListDao(ref.read(databaseProvider));
});

//
final wordDaoProvider = Provider<EspJpnWordDao>((ref) {
  return EspJpnWordDao(ref.read(databaseProvider));
});

final conjugationDaoProvider = Provider<ConjugationDao>((ref) {
  return ConjugationDao(ref.read(databaseProvider));
});

final jpnEspWordDaoProvider = Provider<JpnEspWordDao>((ref) {
  return JpnEspWordDao(ref.read(databaseProvider));
});

final jpnEspExampleDaoProvider = Provider<JpnEspExampleDao>((ref) {
  return JpnEspExampleDao(ref.read(databaseProvider));
});

final jpnEspDictionaryDaoProvider = Provider<JpnEspDictionaryDao>((ref) {
  return JpnEspDictionaryDao(ref.read(databaseProvider));
});

final esEnConjugacionDaoProvider = Provider<EsEnConjugacionDao>((ref) {
  return EsEnConjugacionDao(ref.read(databaseProvider));
});
