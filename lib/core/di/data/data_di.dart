import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:my_dic/core/infrastructure/database/dao/local/conjugation_dao.dart';
import 'package:my_dic/core/infrastructure/database/dao/local/dictionary_dao.dart';
import 'package:my_dic/core/infrastructure/database/dao/local/es_en_conjugacion_dao.dart';
import 'package:my_dic/core/infrastructure/database/dao/local/example_dao.dart';
import 'package:my_dic/core/infrastructure/database/dao/local/idiom_dao.dart';
import 'package:my_dic/core/infrastructure/database/dao/local/jpn_esp/jpn_esp_dictionary_dao.dart';
import 'package:my_dic/core/infrastructure/database/dao/local/jpn_esp/jpn_esp_example_dao.dart';
import 'package:my_dic/core/infrastructure/database/dao/local/jpn_esp/jpn_esp_word_dao.dart';
import 'package:my_dic/core/infrastructure/database/dao/local/jpn_esp/jpn_esp_word_status_dao.dart';
import 'package:my_dic/core/infrastructure/database/dao/local/supplement_dao.dart';
import 'package:my_dic/core/infrastructure/database/dao/local/word_dao.dart';
import 'package:my_dic/core/infrastructure/database/dao/local/word_status_dao.dart';
import 'package:my_dic/core/infrastructure/database/database_provider.dart';

import 'package:my_dic/_Framework_Driver/local/drift/DAO/part_of_speech_list_dao.dart';

final databaseProvider = Provider<DatabaseProvider>((ref) {
  return DatabaseProvider();
});

// --dictionary
final dictionaryDaoProvider = Provider<DictionaryDao>((ref) {
  return DictionaryDao(ref.read(databaseProvider));
});

final exampleDaoProvider = Provider<ExampleDao>((ref) {
  return ExampleDao(ref.read(databaseProvider));
});

final idiomDaoProvider = Provider<IdiomDao>((ref) {
  return IdiomDao(ref.read(databaseProvider));
});

final supplementDaoProvider = Provider<SupplementDao>((ref) {
  return SupplementDao(ref.read(databaseProvider));
});

final partOfSpeechListDaoProvider = Provider<PartOfSpeechListDao>((ref) {
  return PartOfSpeechListDao(ref.read(databaseProvider));
});

//
final wordDaoProvider = Provider<WordDao>((ref) {
  return WordDao(ref.read(databaseProvider));
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

final jpnEspWordStatusDaoProvider = Provider<JpnEspWordStatusDao>((ref) {
  return JpnEspWordStatusDao(ref.read(databaseProvider));
});

final esEnConjugacionDaoProvider = Provider<EsEnConjugacionDao>((ref) {
  return EsEnConjugacionDao(ref.read(databaseProvider));
});

final localWordStatusDaoProvider = Provider<WordStatusDao>((ref) {
  return WordStatusDao(ref.read(databaseProvider));
});
