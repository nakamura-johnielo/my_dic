// ignore_for_file: non_constant_identifier_names

import 'package:get_it/get_it.dart';
import 'package:my_dic/_Business_Rule/Usecase/load_rankings/i_load_rankings_presenter.dart';
import 'package:my_dic/_Business_Rule/Usecase/load_rankings/i_load_rankings_use_case.dart';
import 'package:my_dic/_Business_Rule/Usecase/load_rankings/load_rankings_interactor.dart';
import 'package:my_dic/_Business_Rule/Usecase/search_word/i_search_word_presenter.dart';
import 'package:my_dic/_Business_Rule/Usecase/search_word/i_search_word_use_case.dart';
import 'package:my_dic/_Business_Rule/Usecase/search_word/search_word_interactor.dart';
import 'package:my_dic/_Business_Rule/_Domain/Repository_I/i_conjugation_repository.dart';
import 'package:my_dic/_Business_Rule/_Domain/Repository_I/i_esj_dictionary_repository.dart';
import 'package:my_dic/_Business_Rule/_Domain/Repository_I/i_esj_word_repository.dart';
import 'package:my_dic/_Business_Rule/_Domain/Repository_I/i_esp_ranking_repository.dart';
import 'package:my_dic/_Framework_Driver/Database/drift/DAO/conjugation_dao.dart';
import 'package:my_dic/_Framework_Driver/Database/drift/DAO/dictionary_dao.dart';
import 'package:my_dic/_Framework_Driver/Database/drift/DAO/example_dao.dart';
import 'package:my_dic/_Framework_Driver/Database/drift/DAO/idiom_dao.dart';
import 'package:my_dic/_Framework_Driver/Database/drift/DAO/part_of_speech_list_dao.dart';
import 'package:my_dic/_Framework_Driver/Database/drift/DAO/ranking_dao.dart';
import 'package:my_dic/_Framework_Driver/Database/drift/DAO/supplement_dao.dart';
import 'package:my_dic/_Framework_Driver/Database/drift/DAO/word_dao.dart';
import 'package:my_dic/_Framework_Driver/Database/drift/database_provider.dart';
import 'package:my_dic/_Framework_Driver/Repository/drift_conjugacion_repository.dart';
import 'package:my_dic/_Framework_Driver/Repository/drift_esj_dictionary_repository.dart';
import 'package:my_dic/_Framework_Driver/Repository/drift_esj_word_repository.dart';
import 'package:my_dic/_Framework_Driver/Repository/wiki_esp_ranking_repository.dart';
import 'package:my_dic/_Interface_Adapter/Controller/ranking_controller.dart';
import 'package:my_dic/_Interface_Adapter/Presenter/load_ranking_presenter_impl.dart';
import 'package:my_dic/_Interface_Adapter/Presenter/search_word_presenter_impl.dart';
import 'package:my_dic/_Interface_Adapter/ViewModel/ranking_view_model.dart';
import 'package:my_dic/_Interface_Adapter/ViewModel/search_view_model.dart';
import 'package:my_dic/_Interface_Adapter/Controller/buffer_controller.dart';
import 'package:my_dic/_View/ranking/ranking_fragment.dart';

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
      () => DriftEsjDictionaryRepository(
            DI<DictionaryDao>(),
            DI<ExampleDao>(),
            DI<IdiomDao>(),
            DI<SupplementDao>(),
          ));
  DI.registerFactory<IEsjWordRepository>(
      () => DriftEsjWordRepository(DI<WordDao>()));
  DI.registerFactory<IConjugacionsRepository>(
      () => DriftConjugacionRepository(DI<ConjugationDao>()));

  DI.registerFactory<IEspRankingRepository>(
      () => WikiEspRankingRepository(DI<RankingDao>()));

  //presenter
  DI.registerFactory<ISearchWordPresenter>(
      () => SearchWordPresenterImpl(DI<SearchViewModel>()));
  DI.registerFactory<ILoadRankingsPresenter>(
      () => LoadRankingPresenterImpl(DI<RankingViewModel>()));

  //usecase
  DI.registerFactory<ISearchWordUseCase>(() => SearchWordInteractor(
      DI<IEsjWordRepository>(), DI<ISearchWordPresenter>()));
  DI.registerFactory<ILoadRankingsUseCase>(() => LoadRankingsInteractor(
      DI<IEspRankingRepository>(), DI<ILoadRankingsPresenter>()));

  //controller
  DI.registerFactory<BufferController>(
      () => BufferController(DI<ISearchWordUseCase>()));
  DI.registerFactory<RankingController>(
      () => RankingController(DI<ILoadRankingsUseCase>()));

  //viewmodel
  //singleton
  DI.registerLazySingleton<SearchViewModel>(() => SearchViewModel());
  DI.registerLazySingleton<RankingViewModel>(() => RankingViewModel());

  //UI
  DI.registerFactory<RankingFragment>(
      () => RankingFragment(DI<RankingController>()));
}
