// ignore_for_file: non_constant_identifier_names

import 'package:get_it/get_it.dart';
import 'package:my_dic/_Business_Rule/_Domain/Repository_I/i_esj_dictionary_repository.dart';
import 'package:my_dic/_Framework_Driver/Database/drift/DAO/conjugation_dao.dart';
import 'package:my_dic/_Framework_Driver/Database/drift/DAO/dictionary_dao.dart';
import 'package:my_dic/_Framework_Driver/Database/drift/DAO/example_dao.dart';
import 'package:my_dic/_Framework_Driver/Database/drift/DAO/idiom_dao.dart';
import 'package:my_dic/_Framework_Driver/Database/drift/DAO/part_of_speech_list_dao.dart';
import 'package:my_dic/_Framework_Driver/Database/drift/DAO/ranking_dao.dart';
import 'package:my_dic/_Framework_Driver/Database/drift/DAO/supplement_dao.dart';
import 'package:my_dic/_Framework_Driver/Database/drift/DAO/word_dao.dart';
import 'package:my_dic/_Framework_Driver/Database/drift/database_provider.dart';
import 'package:my_dic/_Framework_Driver/Repository/drift_esj_dictionary_repository.dart';

final DI = GetIt.instance;

void setupLocator() {
  //Database
  DI.registerSingleton<DatabaseProvider>(DatabaseProvider());

  //DAOにDatabase注入
  DI.registerFactory<ConjugationDao>(
      () => ConjugationDao(DI<DatabaseProvider>()));
  DI.registerFactory<DictionaryDao>(
      () => DictionaryDao(DI<DatabaseProvider>()));
  DI.registerFactory<ExampleDao>(() => ExampleDao(DI<DatabaseProvider>()));
  DI.registerFactory<IdiomDao>(() => IdiomDao(DI<DatabaseProvider>()));
  DI.registerFactory<PartOfSpeechListDao>(
      () => PartOfSpeechListDao(DI<DatabaseProvider>()));
  DI.registerFactory<RankingDao>(() => RankingDao(DI<DatabaseProvider>()));
  DI.registerFactory<SupplementDao>(
      () => SupplementDao(DI<DatabaseProvider>()));
  DI.registerFactory<WordDao>(() => WordDao(DI<DatabaseProvider>()));

  //repository
  DI.registerFactory<IEsjDictionaryRepository>(
      () => DriftEsjDictionaryRepository(DI<DictionaryDao>()));
}
