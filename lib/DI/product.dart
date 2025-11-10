// ignore_for_file: non_constant_identifier_names

import 'package:flutter/widgets.dart';
import 'package:get_it/get_it.dart';
import 'package:my_dic/Components/modal/ranking_filter_modal.dart';
import 'package:my_dic/Components/my_word_card_modal.dart';
import 'package:my_dic/Components/status_buttons.dart';
import 'package:my_dic/_Business_Rule/Usecase/esp_jpn_status/esp_jpn_status_interactor.dart';
import 'package:my_dic/_Business_Rule/Usecase/fetch_conjugation/fetch_conjugation_interactor.dart';
import 'package:my_dic/_Business_Rule/Usecase/fetch_conjugation/i_fetch_conjugation_presenter.dart';
import 'package:my_dic/_Business_Rule/Usecase/fetch_conjugation/i_fetch_conjugation_use_case.dart';
import 'package:my_dic/_Business_Rule/Usecase/fetch_dictionary/fetch_dictionary_interactor.dart';
import 'package:my_dic/_Business_Rule/Usecase/fetch_dictionary/i_fetch_dictionary_presenter.dart';
import 'package:my_dic/_Business_Rule/Usecase/fetch_dictionary/i_fetch_dictionary_use_case.dart';
import 'package:my_dic/_Business_Rule/Usecase/fetch_jpn_esp_dictionary/fetch_jpn_esp_dictionary_interactor.dart';
import 'package:my_dic/_Business_Rule/Usecase/fetch_jpn_esp_dictionary/i_fetch_jpn_esp_dictionary_presenter.dart';
import 'package:my_dic/_Business_Rule/Usecase/fetch_jpn_esp_dictionary/i_fetch_jpn_esp_dictionary_use_case.dart';
import 'package:my_dic/_Business_Rule/Usecase/judge_search_word/i_judge_search_word_use_case.dart';
import 'package:my_dic/_Business_Rule/Usecase/judge_search_word/judge_search_word_interactor.dart';
import 'package:my_dic/_Business_Rule/Usecase/load_my_word/i_load_my_word_presenter.dart';
import 'package:my_dic/_Business_Rule/Usecase/load_my_word/i_load_my_word_use_case.dart';
import 'package:my_dic/_Business_Rule/Usecase/load_my_word/load_my_word_interactor.dart';
import 'package:my_dic/_Business_Rule/Usecase/locate_ranking_pagenation/i_locate_ranking_pagenation_presenter.dart';
import 'package:my_dic/_Business_Rule/Usecase/locate_ranking_pagenation/i_locate_ranking_pagenation_use_case.dart';
import 'package:my_dic/_Business_Rule/Usecase/locate_ranking_pagenation/locate_ranking_pagenation_interactor.dart';
import 'package:my_dic/_Business_Rule/Usecase/my_word/create/handle_word_registration/handle_word_registration_interactor.dart';
import 'package:my_dic/_Business_Rule/Usecase/my_word/create/handle_word_registration/i_handle_word_registration_use_case.dart';
import 'package:my_dic/_Business_Rule/Usecase/my_word/delete/delete_my_word/delete_my_word_interactor.dart';
import 'package:my_dic/_Business_Rule/Usecase/my_word/delete/delete_my_word/i_delete_my_word_use_case.dart';
import 'package:my_dic/_Business_Rule/Usecase/my_word/i_my_word_fragment_presenter.dart';
import 'package:my_dic/_Business_Rule/Usecase/my_word/create/register_my_word/i_register_my_word_use_case.dart';
import 'package:my_dic/_Business_Rule/Usecase/my_word/create/register_my_word/register_my_word_interactor.dart';
import 'package:my_dic/_Business_Rule/Usecase/my_word/update/update_my_word/i_update_my_word_use_case.dart';
import 'package:my_dic/_Business_Rule/Usecase/my_word/update/update_my_word/update_my_word_interactor.dart';
/* import 'package:my_dic/_Business_Rule/Usecase/add_filter/add_filter_interactor.dart';
import 'package:my_dic/_Business_Rule/Usecase/add_filter/i_add_filter_presenter.dart';
import 'package:my_dic/_Business_Rule/Usecase/add_filter/i_add_filter_use_case.dart';
import 'package:my_dic/_Business_Rule/Usecase/delete_filter/delete_filter_interactor.dart';
import 'package:my_dic/_Business_Rule/Usecase/delete_filter/i_delete_filter_presenter.dart';
import 'package:my_dic/_Business_Rule/Usecase/delete_filter/i_delete_filter_use_case.dart'; */
/* import 'package:my_dic/_Business_Rule/Usecase/load_rankings22/i_load_rankings_presenter.dart';
import 'package:my_dic/_Business_Rule/Usecase/load_rankings22/i_load_rankings_use_case.dart';
import 'package:my_dic/_Business_Rule/Usecase/load_rankings22/load_rankings_interactor.dart'; */
import 'package:my_dic/_Business_Rule/Usecase/search_word/i_search_word_presenter.dart';
import 'package:my_dic/_Business_Rule/Usecase/search_word/i_search_word_use_case.dart';
import 'package:my_dic/_Business_Rule/Usecase/search_word/search_word_interactor.dart';
import 'package:my_dic/_Business_Rule/Usecase/load_rankings/i_load_rankings_presenter.dart';
import 'package:my_dic/_Business_Rule/Usecase/load_rankings/i_load_rankings_use_case.dart';
import 'package:my_dic/_Business_Rule/Usecase/load_rankings/load_rankings_interactor.dart';
import 'package:my_dic/_Business_Rule/Usecase/update_my_word_status/i_update_my_word_status_presenter.dart';
import 'package:my_dic/_Business_Rule/Usecase/update_my_word_status/i_update_my_word_status_use_case.dart';
import 'package:my_dic/_Business_Rule/Usecase/update_my_word_status/update_my_word_status_interactor.dart';
import 'package:my_dic/_Business_Rule/Usecase/update_ranking_filter/i_update_ranking_filter_presenter.dart';
import 'package:my_dic/_Business_Rule/Usecase/update_ranking_filter/i_update_ranking_filter_use_case.dart';
import 'package:my_dic/_Business_Rule/Usecase/update_ranking_filter/update_ranking_filter_interactor.dart';
import 'package:my_dic/_Business_Rule/Usecase/update_status/i_update_status_presenter.dart';
import 'package:my_dic/_Business_Rule/Usecase/update_status/i_update_status_use_case.dart';
import 'package:my_dic/_Business_Rule/Usecase/update_status/update_status_interactor.dart';
import 'package:my_dic/_Business_Rule/_Domain/Repository_I/i_conjugation_repository.dart';
import 'package:my_dic/_Business_Rule/_Domain/Repository_I/i_esj_dictionary_repository.dart';
import 'package:my_dic/_Business_Rule/_Domain/Repository_I/i_esj_word_repository.dart';
import 'package:my_dic/_Business_Rule/_Domain/Repository_I/i_esp_ranking_repository.dart';
import 'package:my_dic/_Business_Rule/_Domain/Repository_I/i_jpn_esp_dictionary_repository.dart';
import 'package:my_dic/_Business_Rule/_Domain/Repository_I/i_jpn_esp_word_repository.dart';
import 'package:my_dic/_Business_Rule/_Domain/Repository_I/i_my_word_repository.dart';
import 'package:my_dic/_Framework_Driver/Database/drift/DAO/conjugation_dao.dart';
import 'package:my_dic/_Framework_Driver/Database/drift/DAO/dictionary_dao.dart';
import 'package:my_dic/_Framework_Driver/Database/drift/DAO/example_dao.dart';
import 'package:my_dic/_Framework_Driver/Database/drift/DAO/idiom_dao.dart';
import 'package:my_dic/_Framework_Driver/Database/drift/DAO/jpn_esp/jpn_esp_dictionary_dao.dart';
import 'package:my_dic/_Framework_Driver/Database/drift/DAO/jpn_esp/jpn_esp_example_dao.dart';
import 'package:my_dic/_Framework_Driver/Database/drift/DAO/jpn_esp/jpn_esp_word_dao.dart';
import 'package:my_dic/_Framework_Driver/Database/drift/DAO/jpn_esp/jpn_esp_word_status_dao.dart';
import 'package:my_dic/_Framework_Driver/Database/drift/DAO/my_word_dao.dart';
import 'package:my_dic/_Framework_Driver/Database/drift/DAO/my_word_status_dao.dart';
import 'package:my_dic/_Framework_Driver/Database/drift/DAO/part_of_speech_list_dao.dart';
import 'package:my_dic/_Framework_Driver/Database/drift/DAO/ranking_dao.dart';
import 'package:my_dic/_Framework_Driver/Database/drift/DAO/supplement_dao.dart';
import 'package:my_dic/_Framework_Driver/Database/drift/DAO/word_dao.dart';
import 'package:my_dic/_Framework_Driver/Database/drift/DAO/word_status_dao.dart';
import 'package:my_dic/_Framework_Driver/Database/drift/database_provider.dart';
import 'package:my_dic/_Framework_Driver/Repository/drift_conjugacion_repository.dart';
import 'package:my_dic/_Framework_Driver/Repository/drift_esj_dictionary_repository.dart';
import 'package:my_dic/_Framework_Driver/Repository/drift_esj_word_repository.dart';
import 'package:my_dic/_Framework_Driver/Repository/drift_jpn_esp_dictionary_repository.dart';
import 'package:my_dic/_Framework_Driver/Repository/drift_jpn_esp_word_repository.dart';
import 'package:my_dic/_Framework_Driver/Repository/drift_my_word_repository.dart';
import 'package:my_dic/_Framework_Driver/Repository/wiki_esp_ranking_repository.dart';
import 'package:my_dic/_Interface_Adapter/Controller/jpn_esp_word_page_controller.dart';
import 'package:my_dic/_Interface_Adapter/Controller/my_word_controller.dart';
import 'package:my_dic/_Interface_Adapter/Controller/ranking_controller.dart';
import 'package:my_dic/_Interface_Adapter/Controller/word_page_controller.dart';
import 'package:my_dic/_Interface_Adapter/Presenter/conjugacion_presenter.dart';
import 'package:my_dic/_Interface_Adapter/Presenter/dictionary_presenter.dart';
import 'package:my_dic/_Interface_Adapter/Presenter/jpn_esp_word_page_presenter_impl.dart';
import 'package:my_dic/_Interface_Adapter/Presenter/load_my_word_presenter_impl.dart';
import 'package:my_dic/_Interface_Adapter/Presenter/locate_ranking_pagenation_presenter_impl.dart';
import 'package:my_dic/_Interface_Adapter/Presenter/my_word_fragment_presenter_impl.dart';
import 'package:my_dic/_Interface_Adapter/Presenter/search_word_presenter_impl.dart';
import 'package:my_dic/_Interface_Adapter/Presenter/load_rankings_presenter_impl.dart';
import 'package:my_dic/_Interface_Adapter/Presenter/update_my_word_status_presenter_impl.dart';
import 'package:my_dic/_Interface_Adapter/Presenter/update_ranking_filter_presenter_impl.dart';
import 'package:my_dic/_Interface_Adapter/Presenter/update_status_presenter_impl.dart';
import 'package:my_dic/_Interface_Adapter/ViewModel/jpn_esp_word_page_view_model.dart';
import 'package:my_dic/_Interface_Adapter/ViewModel/main_view_model.dart';
import 'package:my_dic/_Interface_Adapter/ViewModel/my_word_view_model.dart';
import 'package:my_dic/_Interface_Adapter/ViewModel/note_view_model.dart';
import 'package:my_dic/_Interface_Adapter/ViewModel/ranking_view_model.dart';
import 'package:my_dic/_Interface_Adapter/ViewModel/search_view_model.dart';
import 'package:my_dic/_Interface_Adapter/Controller/buffer_controller.dart';
import 'package:my_dic/_View/my_word/create_word_modal.dart';
import 'package:my_dic/_View/my_word/my_word_fragment.dart';
import 'package:my_dic/_View/ranking/ranking_fragment.dart';
import 'package:my_dic/_View/word_page/conjugacion_fragment.dart';
import 'package:my_dic/_View/word_page/dictionary_fragment.dart';
import 'package:my_dic/_View/word_page/jpn_esp/jpn_esp_dictionary_fragment.dart';
import 'package:tuple/tuple.dart';

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
  DI.registerFactory<WordStatusDao>(
      () => WordStatusDao(DI<DatabaseProvider>()));
  DI.registerFactory<MyWordStatusDao>(
      () => MyWordStatusDao(DI<DatabaseProvider>()));
  DI.registerFactory<MyWordDao>(() => MyWordDao(DI<DatabaseProvider>()));
  DI.registerFactory<JpnEspWordDao>(
      () => JpnEspWordDao(DI<DatabaseProvider>()));
  DI.registerFactory<JpnEspExampleDao>(
      () => JpnEspExampleDao(DI<DatabaseProvider>()));
  DI.registerFactory<JpnEspWordStatusDao>(
      () => JpnEspWordStatusDao(DI<DatabaseProvider>()));
  DI.registerFactory<JpnEspDictionaryDao>(
      () => JpnEspDictionaryDao(DI<DatabaseProvider>()));

  //repository
  DI.registerFactory<IEsjDictionaryRepository>(
      () => DriftEsjDictionaryRepository(
            DI<DictionaryDao>(),
            DI<ExampleDao>(),
            DI<IdiomDao>(),
            DI<SupplementDao>(),
          ));
  DI.registerFactory<IEsjWordRepository>(
      () => DriftEsjWordRepository(DI<WordDao>(), DI<WordStatusDao>()));
  DI.registerFactory<IConjugacionsRepository>(
      () => DriftConjugacionRepository(DI<ConjugationDao>()));
  DI.registerFactory<IEspRankingRepository>(
      () => WikiEspRankingRepository(DI<RankingDao>()));
  DI.registerFactory<IMyWordRepository>(
      () => DriftMyWordRepository(DI<MyWordDao>(), DI<MyWordStatusDao>()));
  DI.registerFactory<IJpnEspWordRepository>(() => DriftJpnEspWordRepository(
      DI<JpnEspWordDao>(), DI<JpnEspDictionaryDao>()));
  DI.registerFactory<IJpnEspDictionaryRepository>(() =>
      DriftJpnEspDictionaryRepository(
          DI<JpnEspDictionaryDao>(), DI<JpnEspExampleDao>()));

  //
  //
  //
/*============Ranking ======================================================= */
  //presenter
  /* DI.registerFactory<ILoadRankingsPresenter>(
      () => LoadRankingPresenterImpl(DI<RankingViewModel>())); */
  DI.registerFactory<ILoadRankingsPresenter>(
      () => LoadRankingsPresenterImpl(DI<RankingViewModel>()));
  DI.registerFactory<IUpdateRankingFilterPresenter>(
      () => UpdateRankingFilterPresenterImpl(DI<RankingViewModel>()));
  DI.registerFactory<ILocateRankingPagenationPresenter>(
      () => LocateRankingPagenationPresenterImpl(DI<RankingViewModel>()));
  DI.registerFactory<IUpdateStatusPresenter>(
      () => UpdateStatusPresenterImpl(DI<RankingViewModel>()));

  /* DI.registerFactory<IAddFilterPresenter>(
      () => AddFilterPresenterImpl(DI<RankingViewModel>()));
  DI.registerFactory<IDeleteFilterPresenter>(
      () => DeleteFilterPresenterImpl(DI<RankingViewModel>())); */

  //usecase
  /* DI.registerFactory<ILoadRankingsUseCase>(() => LoadRankingsInteractor(
      DI<IEspRankingRepository>(), DI<ILoadRankingsPresenter>())); */
  DI.registerFactory<ILoadRankingsUseCase>(() => LoadRankingsInteractor(
      DI<ILoadRankingsPresenter>(), DI<IEspRankingRepository>()));
  DI.registerFactory<IUpdateRankingFilterUseCase>(
      () => UpdateRankingFilterInteractor(DI<IUpdateRankingFilterPresenter>()));
  DI.registerFactory<ILocateRankingPagenationUseCase>(() =>
      LocateRankingPagenationInteractor(
          DI<ILocateRankingPagenationPresenter>()));
  DI.registerFactory<IUpdateStatusUseCase>(() => UpdateStatusInteractor(
      DI<IUpdateStatusPresenter>(), DI<IEsjWordRepository>()));

  /* DI.registerFactory<IAddFilterUseCase>(() => AddFilterInteractor(
      DI<IAddFilterPresenter>(), DI<IEspRankingRepository>()));
  DI.registerFactory<IDeleteFilterUseCase>(
      () => DeleteFilterInteractor(DI<IDeleteFilterPresenter>())); */

  //controller
  DI.registerFactory<RankingController>(() => RankingController(
        //DI<ILoadRankingsUseCase>(),
        DI<RankingViewModel>(),
        DI<ILoadRankingsUseCase>(),
        DI<IUpdateRankingFilterUseCase>(),
        DI<ILocateRankingPagenationUseCase>(),
        DI<IUpdateStatusUseCase>(),
      ));

  //viewmodel
  //singleton
  DI.registerLazySingleton<RankingViewModel>(() => RankingViewModel());

  //UI
  DI.registerFactory<RankingFragment>(
      () => RankingFragment(DI<RankingController>()));
  DI.registerFactory<RankingFilterModal>(
      () => RankingFilterModal(DI<RankingController>()));
/*============Ranking ================================================= */
  //
  //

  //
/*===========Search =====================================================-====== */
  //presenter
  DI.registerFactory<ISearchWordPresenter>(
      () => SearchWordPresenterImpl(DI<SearchViewModel>()));

  //usecase IJudgeSearchWordUseCase
  DI.registerFactory<ISearchWordUseCase>(() => SearchWordInteractor(
      DI<IEsjWordRepository>(),
      DI<ISearchWordPresenter>(),
      DI<IJpnEspWordRepository>(),
      DI<IConjugacionsRepository>()));
  DI.registerFactory<IJudgeSearchWordUseCase>(
      () => JudgeSearchWordInteractor());

  //controller
  DI.registerFactory<BufferController>(() => BufferController(
      DI<ISearchWordUseCase>(), DI<IJudgeSearchWordUseCase>()));

  //viewmodel
  //singleton
  DI.registerLazySingleton<SearchViewModel>(() => SearchViewModel());
/*===========Search =====================================================-====== */
  //
  //

  //

  //
/*===========wordPage =====================================================-====== */

  //presenter
  DI.registerFactory<IFetchConjugationPresenter>(
      () => ConjugacionFragmentPresenterImpl(DI<MainViewModel>()));
  DI.registerFactory<IFetchDictionaryPresenter>(
      () => DictionaryFragmentPresenterImpl(DI<MainViewModel>()));
  DI.registerFactory<IFetchJpnEspDictionaryPresenter>(
      () => JpnEspWordPagePresenterImpl(DI<JpnEspWordPageViewModel>()));

  //usecase
  DI.registerFactory<IFetchConjugationUseCase>(() => FetchConjugationInteractor(
      DI<IFetchConjugationPresenter>(), DI<IConjugacionsRepository>()));
  DI.registerFactory<IFetchDictionaryUseCase>(() => FetchDictionaryInteractor(
      DI<IFetchDictionaryPresenter>(), DI<IEsjDictionaryRepository>()));
  DI.registerFactory<IFetchJpnEspDictionaryUseCase>(() =>
      FetchJpnEspDictionaryInteractor(DI<IFetchJpnEspDictionaryPresenter>(),
          DI<IJpnEspDictionaryRepository>()));

  //controller
  DI.registerFactory<WordPageController>(() => WordPageController(
      DI<IFetchDictionaryUseCase>(),
      DI<IFetchConjugationUseCase>(),
      DI<IUpdateStatusUseCase>()));

  DI.registerFactory<JpnEspWordPageController>(
      () => JpnEspWordPageController(DI<IFetchJpnEspDictionaryUseCase>()));

//viewmodel
  //singleton
  DI.registerLazySingleton<MainViewModel>(() => MainViewModel());
  DI.registerLazySingleton<JpnEspWordPageViewModel>(
      () => JpnEspWordPageViewModel());

  //UI
  DI.registerFactoryParam<DictionaryFragment, WordPageChildInputData, void>(
      (input, _) =>
          //wordId,key
          DictionaryFragment(
              key: input.key,
              wordId: input.wordId,
              wordPageController: DI<WordPageController>()));

  DI.registerFactoryParam<ConjugacionFragment, WordPageChildInputData, void>(
      (input, _) =>
          //wordId,key
          ConjugacionFragment(
              key: input.key,
              wordId: input.wordId,
              wordPageController: DI<WordPageController>()));

  DI.registerFactoryParam<JpnEspDictionaryFragment, WordPageChildInputData, void>(
      (input, _) =>
          //wordId,key
          JpnEspDictionaryFragment(
              key: input.key,
              wordId: input.wordId,
              wordPageController: DI<JpnEspWordPageController>()));

/*===========wordPage =====================================================-====== */
  //
  //

  //
/*===========my word =====================================================-====== */

  //presenter
  DI.registerFactory<ILoadMyWordPresenter>(
      () => LoadMyWordPresenterImpl(DI<MyWordViewModel>()));
  DI.registerFactory<IUpdateMyWordStatusPresenter>(
      () => UpdateMyWordStatusPresenterImpl(DI<MyWordViewModel>()));
  DI.registerFactory<IMyWordFragmentPresenter>(
      () => MyWordFragmentPresenterImpl(DI<MyWordViewModel>()));

  //usecase
  DI.registerFactory<ILoadMyWordUseCase>(() => LoadMyWordInteractor(
      DI<ILoadMyWordPresenter>(), DI<IMyWordRepository>()));
  DI.registerFactory<IUpdateMyWordStatusUseCase>(() =>
      UpdateMyWordStatusInteractor(
          DI<IUpdateMyWordStatusPresenter>(), DI<IMyWordRepository>()));
  DI.registerFactory<IRegisterMyWordUseCase>(() => RegisterMyWordInteractor(
      DI<IMyWordFragmentPresenter>(), DI<IMyWordRepository>()));
  DI.registerFactory<IHandleWordRegistrationUseCase>(
      () => HandleWordRegistrationInteractor());
  DI.registerFactory<IUpdateMyWordUseCase>(() => UpdateMyWordInteractor(
      DI<IMyWordFragmentPresenter>(), DI<IMyWordRepository>()));
  DI.registerFactory<IDeleteMyWordUseCase>(() => DeleteMyWordInteractor(
      DI<IMyWordFragmentPresenter>(), DI<IMyWordRepository>()));

  //controller
  DI.registerFactory<MyWordController>(() => MyWordController(
        DI<ILoadMyWordUseCase>(),
        DI<IUpdateMyWordStatusUseCase>(),
        DI<IRegisterMyWordUseCase>(),
        DI<IHandleWordRegistrationUseCase>(),
        DI<IUpdateMyWordUseCase>(),
        DI<IDeleteMyWordUseCase>(),
      ));

  //viewmodel
  //singleton
  DI.registerLazySingleton<MyWordViewModel>(() => MyWordViewModel());

  //UI
  DI.registerFactory<MyWordFragment>(
      () => MyWordFragment(DI<MyWordController>()));
  DI.registerFactory<WordRegistrationModal>(
      () => WordRegistrationModal(DI<MyWordController>()));
  /* DI.registerFactory<MyWordCardModal>(
      () => MyWordCardModal(DI<MyWordController>())); */

/*===========my word =====================================================-====== */
  //
  //

  //
/*===========note =====================================================-====== */
  //presenter
  /* DI.registerFactory<ISearchWordPresenter>(
      () => SearchWordPresenterImpl(DI<SearchViewModel>())); */

  //usecase
  /* DI.registerFactory<ISearchWordUseCase>(() => SearchWordInteractor(
      DI<IEsjWordRepository>(), DI<ISearchWordPresenter>())); */

  //controller
  /* DI.registerFactory<BufferController>(
      () => BufferController(DI<ISearchWordUseCase>())); */

  //viewmodel
  //singleton
  DI.registerLazySingleton<NoteViewModel>(() => NoteViewModel());
/*===========note =====================================================-====== */
  //
  //

  //
  //
  //
  DI.registerFactory<EspJpnStatusInteractor>(
      () => EspJpnStatusInteractor(DI<IEsjWordRepository>()));

  DI.registerFactory<WordStatusViewModel>(
      () => WordStatusViewModel(DI<EspJpnStatusInteractor>()));
}

class WordPageChildInputData {
  int wordId;
  PageStorageKey? key;
  WordPageChildInputData({required this.wordId, this.key});
}
