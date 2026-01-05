import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:my_dic/core/infrastructure/database/drift/daos/esp_jpn/conjugation_dao.dart';
import 'package:my_dic/core/infrastructure/database/drift/daos/esp_jpn/dictionary_dao.dart';
import 'package:my_dic/core/infrastructure/database/drift/daos/es_en_conjugacion_dao.dart';
import 'package:my_dic/core/infrastructure/database/drift/daos/esp_jpn/example_dao.dart';
import 'package:my_dic/core/infrastructure/database/drift/daos/esp_jpn/idiom_dao.dart';
import 'package:my_dic/core/infrastructure/database/drift/daos/jpn_esp/jpn_esp_dictionary_dao.dart';
import 'package:my_dic/core/infrastructure/database/drift/daos/jpn_esp/jpn_esp_example_dao.dart';
import 'package:my_dic/core/infrastructure/database/drift/daos/jpn_esp/jpn_esp_word_dao.dart';
import 'package:my_dic/core/infrastructure/database/drift/daos/jpn_esp/jpn_esp_word_status_dao.dart';
import 'package:my_dic/core/infrastructure/database/drift/daos/esp_jpn/supplement_dao.dart';
import 'package:my_dic/core/infrastructure/database/drift/daos/esp_jpn/esp_jpn_word_dao.dart';
import 'package:my_dic/core/infrastructure/database/drift/daos/esp_jpn/esp_jpn_word_status_dao.dart';
import 'package:my_dic/core/infrastructure/database/shared_preferences/shared_preferences.dart';
import 'package:my_dic/core/infrastructure/database/shared_preferences/shared_preferences_syncstatus_dao.dart';
import 'package:my_dic/core/infrastructure/database/firebase/daos/firebase_word_status_dao.dart';
import 'package:my_dic/core/infrastructure/database/drift/database_provider.dart';

import 'package:my_dic/core/infrastructure/database/drift/daos/esp_jpn/part_of_speech_list_dao.dart';
import 'package:my_dic/core/infrastructure/database/firebase/firebase_provider.dart';

final databaseProvider = Provider<DatabaseProvider>((ref) {
  return DatabaseProvider();
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

final jpnEspWordStatusDaoProvider = Provider<JpnEspWordStatusDao>((ref) {
  return JpnEspWordStatusDao(ref.read(databaseProvider));
});

final esEnConjugacionDaoProvider = Provider<EsEnConjugacionDao>((ref) {
  return EsEnConjugacionDao(ref.read(databaseProvider));
});

//=======wordstatus===============--
final localWordStatusDaoProvider = Provider<EspJpnWordStatusDao>((ref) {
  return EspJpnWordStatusDao(ref.read(databaseProvider));
});

final remoteWordStatusDaoProvider =
    Provider((ref) => FirebaseWordStatusDao(ref.watch(firestoreDBProvider)));

final sharedPreferenceSyncStatusDaoProvider = Provider((ref) =>
    SharedPreferencesSyncStatusDao(ref.watch(sharedPreferencesProvider)));
