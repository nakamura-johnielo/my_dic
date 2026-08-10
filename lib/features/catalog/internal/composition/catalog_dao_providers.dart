import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:my_dic/core/di/data/data_di.dart';
import 'package:my_dic/features/catalog/internal/infrastructure/drift/dao/esp_jpn/conjugation_dao.dart';
import 'package:my_dic/features/catalog/internal/infrastructure/drift/dao/esp_jpn/dictionary_dao.dart';
import 'package:my_dic/features/catalog/internal/infrastructure/drift/dao/esp_jpn/esp_jpn_word_dao.dart';
import 'package:my_dic/features/catalog/internal/infrastructure/drift/dao/esp_jpn/example_dao.dart';
import 'package:my_dic/features/catalog/internal/infrastructure/drift/dao/esp_jpn/idiom_dao.dart';
import 'package:my_dic/features/catalog/internal/infrastructure/drift/dao/esp_jpn/part_of_speech_list_dao.dart';
import 'package:my_dic/features/catalog/internal/infrastructure/drift/dao/esp_jpn/supplement_dao.dart';
import 'package:my_dic/features/catalog/internal/infrastructure/drift/dao/jpn_esp/jpn_esp_dictionary_dao.dart';
import 'package:my_dic/features/catalog/internal/infrastructure/drift/dao/jpn_esp/jpn_esp_example_dao.dart';
import 'package:my_dic/features/catalog/internal/infrastructure/drift/dao/jpn_esp/jpn_esp_word_dao.dart';

final dictionaryDaoProvider = Provider<EspjpnDictionaryDao>(
    (ref) => EspjpnDictionaryDao(ref.read(databaseProvider)));
final exampleDaoProvider = Provider<EspJpnExampleDao>(
    (ref) => EspJpnExampleDao(ref.read(databaseProvider)));
final idiomDaoProvider = Provider<EspJpnIdiomDao>(
    (ref) => EspJpnIdiomDao(ref.read(databaseProvider)));
final supplementDaoProvider = Provider<EspJpnSupplementDao>(
    (ref) => EspJpnSupplementDao(ref.read(databaseProvider)));
final partOfSpeechListDaoProvider = Provider<PartOfSpeechListDao>(
    (ref) => PartOfSpeechListDao(ref.read(databaseProvider)));
final wordDaoProvider =
    Provider<EspJpnWordDao>((ref) => EspJpnWordDao(ref.read(databaseProvider)));
final conjugationDaoProvider = Provider<ConjugationDao>(
    (ref) => ConjugationDao(ref.read(databaseProvider)));
final jpnEspWordDaoProvider =
    Provider<JpnEspWordDao>((ref) => JpnEspWordDao(ref.read(databaseProvider)));
final jpnEspExampleDaoProvider = Provider<JpnEspExampleDao>(
    (ref) => JpnEspExampleDao(ref.read(databaseProvider)));
final jpnEspDictionaryDaoProvider = Provider<JpnEspDictionaryDao>(
    (ref) => JpnEspDictionaryDao(ref.read(databaseProvider)));
