import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:my_dic/Components/status_buttons.dart';
import 'package:my_dic/_Business_Rule/Usecase/esp_jpn_status/esp_jpn_status_interactor.dart';
import 'package:my_dic/_Business_Rule/Usecase/fetch_conjugation/fetch_conjugation_interactor.dart';
import 'package:my_dic/_Business_Rule/Usecase/fetch_conjugation/i_fetch_conjugation_use_case.dart';
import 'package:my_dic/_Business_Rule/Usecase/fetch_dictionary/fetch_dictionary_interactor.dart';
import 'package:my_dic/_Business_Rule/Usecase/fetch_dictionary/i_fetch_dictionary_use_case.dart';
import 'package:my_dic/_Business_Rule/Usecase/fetch_jpn_esp_dictionary/fetch_jpn_esp_dictionary_interactor.dart';
import 'package:my_dic/_Business_Rule/Usecase/fetch_jpn_esp_dictionary/i_fetch_jpn_esp_dictionary_use_case.dart';
import 'package:my_dic/_Business_Rule/Usecase/judge_search_word/i_judge_search_word_use_case.dart';
import 'package:my_dic/_Business_Rule/Usecase/judge_search_word/judge_search_word_interactor.dart';
import 'package:my_dic/_Business_Rule/Usecase/load_my_word/i_load_my_word_use_case.dart';
import 'package:my_dic/_Business_Rule/Usecase/load_my_word/load_my_word_interactor.dart';
import 'package:my_dic/_Business_Rule/Usecase/locate_ranking_pagenation/i_locate_ranking_pagenation_use_case.dart';
import 'package:my_dic/_Business_Rule/Usecase/locate_ranking_pagenation/locate_ranking_pagenation_interactor.dart';
import 'package:my_dic/_Business_Rule/Usecase/my_word/create/handle_word_registration/handle_word_registration_interactor.dart';
import 'package:my_dic/_Business_Rule/Usecase/my_word/create/handle_word_registration/i_handle_word_registration_use_case.dart';
import 'package:my_dic/_Business_Rule/Usecase/my_word/delete/delete_my_word/delete_my_word_interactor.dart';
import 'package:my_dic/_Business_Rule/Usecase/my_word/delete/delete_my_word/i_delete_my_word_use_case.dart';
import 'package:my_dic/_Business_Rule/Usecase/my_word/create/register_my_word/i_register_my_word_use_case.dart';
import 'package:my_dic/_Business_Rule/Usecase/my_word/create/register_my_word/register_my_word_interactor.dart';
import 'package:my_dic/_Business_Rule/Usecase/my_word/update/update_my_word/i_update_my_word_use_case.dart';
import 'package:my_dic/_Business_Rule/Usecase/my_word/update/update_my_word/update_my_word_interactor.dart';
import 'package:my_dic/_Business_Rule/Usecase/search_word/i_search_word_use_case.dart';
import 'package:my_dic/_Business_Rule/Usecase/search_word/search_word_interactor.dart';
import 'package:my_dic/_Business_Rule/Usecase/load_rankings/i_load_rankings_use_case.dart';
import 'package:my_dic/_Business_Rule/Usecase/load_rankings/load_rankings_interactor.dart';
import 'package:my_dic/_Business_Rule/Usecase/update_my_word_status/i_update_my_word_status_use_case.dart';
import 'package:my_dic/_Business_Rule/Usecase/update_my_word_status/update_my_word_status_interactor.dart';
import 'package:my_dic/_Business_Rule/Usecase/update_ranking_filter/i_update_ranking_filter_use_case.dart';
import 'package:my_dic/_Business_Rule/Usecase/update_ranking_filter/update_ranking_filter_interactor.dart';
import 'package:my_dic/_Business_Rule/Usecase/update_status/i_update_status_use_case.dart';
import 'package:my_dic/_Business_Rule/Usecase/update_status/update_status_interactor.dart';
import 'package:my_dic/_Business_Rule/_Domain/Entities/verb/conjugacion/conjugacions.dart';
import 'package:my_dic/_Business_Rule/_Domain/Entities/word/word_status.dart';
import 'package:my_dic/_Business_Rule/_Domain/Repository_I/i_conjugation_repository.dart';
import 'package:my_dic/_Business_Rule/_Domain/Repository_I/i_esj_dictionary_repository.dart';
import 'package:my_dic/_Business_Rule/_Domain/Repository_I/i_esj_word_repository.dart';
import 'package:my_dic/_Business_Rule/_Domain/Repository_I/i_esp_ranking_repository.dart';
import 'package:my_dic/_Business_Rule/_Domain/Repository_I/i_jpn_esp_dictionary_repository.dart';
import 'package:my_dic/_Business_Rule/_Domain/Repository_I/i_jpn_esp_word_repository.dart';
import 'package:my_dic/_Business_Rule/_Domain/Repository_I/i_my_word_repository.dart';
import 'package:my_dic/_Framework_Driver/local/drift/DAO/conjugation_dao.dart';
import 'package:my_dic/_Framework_Driver/local/drift/DAO/dictionary_dao.dart';
import 'package:my_dic/_Framework_Driver/local/drift/DAO/es_en_conjugacion_dao.dart';
import 'package:my_dic/_Framework_Driver/local/drift/DAO/example_dao.dart';
import 'package:my_dic/_Framework_Driver/local/drift/DAO/idiom_dao.dart';
import 'package:my_dic/_Framework_Driver/local/drift/DAO/jpn_esp/jpn_esp_dictionary_dao.dart';
import 'package:my_dic/_Framework_Driver/local/drift/DAO/jpn_esp/jpn_esp_example_dao.dart';
import 'package:my_dic/_Framework_Driver/local/drift/DAO/jpn_esp/jpn_esp_word_dao.dart';
import 'package:my_dic/_Framework_Driver/local/drift/DAO/jpn_esp/jpn_esp_word_status_dao.dart';
import 'package:my_dic/_Framework_Driver/local/drift/DAO/my_word_dao.dart';
import 'package:my_dic/_Framework_Driver/local/drift/DAO/my_word_status_dao.dart';
import 'package:my_dic/_Framework_Driver/local/drift/DAO/part_of_speech_list_dao.dart';
import 'package:my_dic/_Framework_Driver/local/drift/DAO/ranking_dao.dart';
import 'package:my_dic/_Framework_Driver/local/drift/DAO/supplement_dao.dart';
import 'package:my_dic/_Framework_Driver/local/drift/DAO/word_dao.dart';
import 'package:my_dic/_Framework_Driver/local/drift/DAO/word_status_dao.dart';
import 'package:my_dic/_Framework_Driver/local/drift/database_provider.dart';
import 'package:my_dic/_Framework_Driver/Repository/drift_conjugacion_repository.dart';
import 'package:my_dic/_Framework_Driver/Repository/drift_es_en_conjugacions_repository.dart';
import 'package:my_dic/_Framework_Driver/Repository/drift_esj_dictionary_repository.dart';
import 'package:my_dic/_Framework_Driver/Repository/drift_esj_word_repository.dart';
import 'package:my_dic/_Framework_Driver/Repository/drift_jpn_esp_dictionary_repository.dart';
import 'package:my_dic/_Framework_Driver/Repository/drift_jpn_esp_word_repository.dart';
import 'package:my_dic/_Framework_Driver/Repository/drift_my_word_repository.dart';
import 'package:my_dic/_Framework_Driver/Repository/wiki_esp_ranking_repository.dart';
import 'package:my_dic/_Interface_Adapter/Controller/buffer_controller.dart';
import 'package:my_dic/_Interface_Adapter/Controller/jpn_esp_word_page_controller.dart';
import 'package:my_dic/_Interface_Adapter/Controller/my_word_controller.dart';
import 'package:my_dic/_Interface_Adapter/Controller/quiz_controller.dart';
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

// ============================================================================
// Database & DAO Providers
// ============================================================================

final databaseProvider = Provider<DatabaseProvider>((ref) {
  return DatabaseProvider();
});

final conjugationDaoProvider = Provider<ConjugationDao>((ref) {
  return ConjugationDao(ref.read(databaseProvider));
});

final dictionaryDaoProvider = Provider<DictionaryDao>((ref) {
  return DictionaryDao(ref.read(databaseProvider));
});

final exampleDaoProvider = Provider<ExampleDao>((ref) {
  return ExampleDao(ref.read(databaseProvider));
});

final idiomDaoProvider = Provider<IdiomDao>((ref) {
  return IdiomDao(ref.read(databaseProvider));
});

final partOfSpeechListDaoProvider = Provider<PartOfSpeechListDao>((ref) {
  return PartOfSpeechListDao(ref.read(databaseProvider));
});

final rankingDaoProvider = Provider<RankingDao>((ref) {
  return RankingDao(ref.read(databaseProvider));
});

final supplementDaoProvider = Provider<SupplementDao>((ref) {
  return SupplementDao(ref.read(databaseProvider));
});

final wordDaoProvider = Provider<WordDao>((ref) {
  return WordDao(ref.read(databaseProvider));
});

final localWordStatusDaoProvider = Provider<WordStatusDao>((ref) {
  return WordStatusDao(ref.read(databaseProvider));
});

final myWordStatusDaoProvider = Provider<MyWordStatusDao>((ref) {
  return MyWordStatusDao(ref.read(databaseProvider));
});

final myWordDaoProvider = Provider<MyWordDao>((ref) {
  return MyWordDao(ref.read(databaseProvider));
});

final jpnEspWordDaoProvider = Provider<JpnEspWordDao>((ref) {
  return JpnEspWordDao(ref.read(databaseProvider));
});

final jpnEspExampleDaoProvider = Provider<JpnEspExampleDao>((ref) {
  return JpnEspExampleDao(ref.read(databaseProvider));
});

final jpnEspWordStatusDaoProvider = Provider<JpnEspWordStatusDao>((ref) {
  return JpnEspWordStatusDao(ref.read(databaseProvider));
});

final jpnEspDictionaryDaoProvider = Provider<JpnEspDictionaryDao>((ref) {
  return JpnEspDictionaryDao(ref.read(databaseProvider));
});

final esEnConjugacionDaoProvider = Provider<EsEnConjugacionDao>((ref) {
  return EsEnConjugacionDao(ref.read(databaseProvider));
});

// ============================================================================
// Repository Providers
// ============================================================================

final esjDictionaryRepositoryProvider =
    Provider<IEsjDictionaryRepository>((ref) {
  return DriftEsjDictionaryRepository(
    ref.read(dictionaryDaoProvider),
    ref.read(exampleDaoProvider),
    ref.read(idiomDaoProvider),
    ref.read(supplementDaoProvider),
  );
});

final esjWordRepositoryProvider = Provider<IEsjWordRepository>((ref) {
  return DriftEsjWordRepository(
    ref.read(wordDaoProvider),
    ref.read(localWordStatusDaoProvider),
  );
});

final conjugacionsRepositoryProvider = Provider<IConjugacionsRepository>((ref) {
  return DriftConjugacionRepository(ref.read(conjugationDaoProvider));
});

final espRankingRepositoryProvider = Provider<IEspRankingRepository>((ref) {
  return WikiEspRankingRepository(ref.read(rankingDaoProvider));
});

final myWordRepositoryProvider = Provider<IMyWordRepository>((ref) {
  return DriftMyWordRepository(
    ref.read(myWordDaoProvider),
    ref.read(myWordStatusDaoProvider),
  );
});

final jpnEspWordRepositoryProvider = Provider<IJpnEspWordRepository>((ref) {
  return DriftJpnEspWordRepository(
    ref.read(jpnEspWordDaoProvider),
    ref.read(jpnEspDictionaryDaoProvider),
  );
});

final jpnEspDictionaryRepositoryProvider =
    Provider<IJpnEspDictionaryRepository>((ref) {
  return DriftJpnEspDictionaryRepository(
    ref.read(jpnEspDictionaryDaoProvider),
    ref.read(jpnEspExampleDaoProvider),
  );
});

final esEnConjugacionRepositoryProvider =
    Provider<DriftEsEnConjugacionRepository>((ref) {
  return DriftEsEnConjugacionRepository(ref.read(esEnConjugacionDaoProvider));
});

// ============================================================================
// ViewModel Providers
// ============================================================================

final rankingViewModelProvider =
    ChangeNotifierProvider<RankingViewModel>((ref) {
  return RankingViewModel();
});

final searchViewModelProvider = ChangeNotifierProvider<SearchViewModel>((ref) {
  return SearchViewModel();
});

final mainViewModelProvider = ChangeNotifierProvider<MainViewModel>((ref) {
  return MainViewModel();
});

final jpnEspWordPageViewModelProvider =
    ChangeNotifierProvider<JpnEspWordPageViewModel>((ref) {
  return JpnEspWordPageViewModel();
});

final myWordViewModelProvider = ChangeNotifierProvider<MyWordViewModel>((ref) {
  return MyWordViewModel();
});

final noteViewModelProvider = ChangeNotifierProvider<NoteViewModel>((ref) {
  return NoteViewModel();
});

// ============================================================================
// Presenter Providers
// ============================================================================

final loadRankingsPresenterProvider = Provider((ref) {
  return LoadRankingsPresenterImpl(ref.read(rankingViewModelProvider));
});

final updateRankingFilterPresenterProvider = Provider((ref) {
  return UpdateRankingFilterPresenterImpl(ref.read(rankingViewModelProvider));
});

final locateRankingPagenationPresenterProvider = Provider((ref) {
  return LocateRankingPagenationPresenterImpl(
      ref.read(rankingViewModelProvider));
});

final updateStatusPresenterProvider = Provider((ref) {
  return UpdateStatusPresenterImpl(ref.read(rankingViewModelProvider));
});

final searchWordPresenterProvider = Provider((ref) {
  return SearchWordPresenterImpl(ref.read(searchViewModelProvider));
});

final fetchConjugationPresenterProvider = Provider((ref) {
  return ConjugacionFragmentPresenterImpl(ref.read(mainViewModelProvider));
});

final fetchDictionaryPresenterProvider = Provider((ref) {
  return DictionaryFragmentPresenterImpl(ref.read(mainViewModelProvider));
});

final fetchJpnEspDictionaryPresenterProvider = Provider((ref) {
  return JpnEspWordPagePresenterImpl(ref.read(jpnEspWordPageViewModelProvider));
});

final loadMyWordPresenterProvider = Provider((ref) {
  return LoadMyWordPresenterImpl(ref.read(myWordViewModelProvider));
});

final updateMyWordStatusPresenterProvider = Provider((ref) {
  return UpdateMyWordStatusPresenterImpl(ref.read(myWordViewModelProvider));
});

final myWordFragmentPresenterProvider = Provider((ref) {
  return MyWordFragmentPresenterImpl(ref.read(myWordViewModelProvider));
});

// ============================================================================
// UseCase Providers
// ============================================================================

final loadRankingsUseCaseProvider = Provider<ILoadRankingsUseCase>((ref) {
  return LoadRankingsInteractor(
    ref.read(loadRankingsPresenterProvider),
    ref.read(espRankingRepositoryProvider),
  );
});

final updateRankingFilterUseCaseProvider =
    Provider<IUpdateRankingFilterUseCase>((ref) {
  return UpdateRankingFilterInteractor(
      ref.read(updateRankingFilterPresenterProvider));
});

final locateRankingPagenationUseCaseProvider =
    Provider<ILocateRankingPagenationUseCase>((ref) {
  return LocateRankingPagenationInteractor(
      ref.read(locateRankingPagenationPresenterProvider));
});

final updateStatusUseCaseProvider = Provider<IUpdateStatusUseCase>((ref) {
  return UpdateStatusInteractor(
    ref.read(updateStatusPresenterProvider),
    ref.read(esjWordRepositoryProvider),
  );
});

final searchWordUseCaseProvider = Provider<ISearchWordUseCase>((ref) {
  return SearchWordInteractor(
    ref.read(esjWordRepositoryProvider),
    ref.read(searchWordPresenterProvider),
    ref.read(jpnEspWordRepositoryProvider),
    ref.read(conjugacionsRepositoryProvider),
  );
});

final judgeSearchWordUseCaseProvider = Provider<IJudgeSearchWordUseCase>((ref) {
  return JudgeSearchWordInteractor();
});

final fetchConjugationUseCaseProvider =
    Provider<IFetchConjugationUseCase>((ref) {
  return FetchConjugationInteractor(
    ref.read(fetchConjugationPresenterProvider),
    ref.read(conjugacionsRepositoryProvider),
  );
});

final fetchDictionaryUseCaseProvider = Provider<IFetchDictionaryUseCase>((ref) {
  return FetchDictionaryInteractor(
    ref.read(fetchDictionaryPresenterProvider),
    ref.read(esjDictionaryRepositoryProvider),
  );
});

final fetchJpnEspDictionaryUseCaseProvider =
    Provider<IFetchJpnEspDictionaryUseCase>((ref) {
  return FetchJpnEspDictionaryInteractor(
    ref.read(fetchJpnEspDictionaryPresenterProvider),
    ref.read(jpnEspDictionaryRepositoryProvider),
  );
});

final loadMyWordUseCaseProvider = Provider<ILoadMyWordUseCase>((ref) {
  return LoadMyWordInteractor(
    ref.read(loadMyWordPresenterProvider),
    ref.read(myWordRepositoryProvider),
  );
});

final updateMyWordStatusUseCaseProvider =
    Provider<IUpdateMyWordStatusUseCase>((ref) {
  return UpdateMyWordStatusInteractor(
    ref.read(updateMyWordStatusPresenterProvider),
    ref.read(myWordRepositoryProvider),
  );
});

final registerMyWordUseCaseProvider = Provider<IRegisterMyWordUseCase>((ref) {
  return RegisterMyWordInteractor(
    ref.read(myWordFragmentPresenterProvider),
    ref.read(myWordRepositoryProvider),
  );
});

final handleWordRegistrationUseCaseProvider =
    Provider<IHandleWordRegistrationUseCase>((ref) {
  return HandleWordRegistrationInteractor();
});

final updateMyWordUseCaseProvider = Provider<IUpdateMyWordUseCase>((ref) {
  return UpdateMyWordInteractor(
    ref.read(myWordFragmentPresenterProvider),
    ref.read(myWordRepositoryProvider),
  );
});

final deleteMyWordUseCaseProvider = Provider<IDeleteMyWordUseCase>((ref) {
  return DeleteMyWordInteractor(
    ref.read(myWordFragmentPresenterProvider),
    ref.read(myWordRepositoryProvider),
  );
});

// ============================================================================
// Controller Providers
// ============================================================================

final rankingControllerProvider = Provider<RankingController>((ref) {
  return RankingController(
    ref.read(rankingViewModelProvider),
    ref.read(loadRankingsUseCaseProvider),
    ref.read(updateRankingFilterUseCaseProvider),
    ref.read(locateRankingPagenationUseCaseProvider),
    ref.read(updateStatusUseCaseProvider),
  );
});

final bufferControllerProvider = Provider<BufferController>((ref) {
  return BufferController(
    ref.read(searchWordUseCaseProvider),
    ref.read(judgeSearchWordUseCaseProvider),
  );
});

final wordPageControllerProvider = Provider<WordPageController>((ref) {
  return WordPageController(
    ref.read(fetchDictionaryUseCaseProvider),
    ref.read(fetchConjugationUseCaseProvider),
    ref.read(updateStatusUseCaseProvider),
  );
});

final jpnEspWordPageControllerProvider =
    Provider<JpnEspWordPageController>((ref) {
  return JpnEspWordPageController(
      ref.read(fetchJpnEspDictionaryUseCaseProvider));
});

final myWordControllerProvider = Provider<MyWordController>((ref) {
  return MyWordController(
    ref.read(loadMyWordUseCaseProvider),
    ref.read(updateMyWordStatusUseCaseProvider),
    ref.read(registerMyWordUseCaseProvider),
    ref.read(handleWordRegistrationUseCaseProvider),
    ref.read(updateMyWordUseCaseProvider),
    ref.read(deleteMyWordUseCaseProvider),
  );
});

final quizControllerProvider = Provider<QuizController>((ref) {
  return QuizController(ref.read(esEnConjugacionRepositoryProvider),
      ref.read(fetchConjugationUseCaseProvider));
});

final quizConjugacionsProvider =
    FutureProvider.autoDispose.family<Conjugacions?, int>(
  (ref, wordId) async {
    final controller = ref.watch(quizControllerProvider);
    return await controller.getConjugaciones(wordId);
  },
);

final quizWordProvider = StateProvider<String>((ref) => "");

// QuizStateをRiverpodで管理するProvider
final quizStateProvider = StateNotifierProvider<QuizStateNotifier, QuizState>(
  (ref) => QuizStateNotifier(),
);
// ============================================================================
// Other Providers
// ============================================================================

final espJpnStatusInteractorProvider = Provider<EspJpnStatusInteractor>((ref) {
  return EspJpnStatusInteractor(ref.read(esjWordRepositoryProvider));
});

final wordStatusViewModelProvider =
    StateNotifierProvider<WordStatusViewModel, Map<int, WordStatus>>((ref) {
  return WordStatusViewModel(ref.read(espJpnStatusInteractorProvider));
});

final wordStatusByIdProvider = Provider.family<WordStatus?, int>((ref, wordId) {
  // 最小限の再ビルドにするためにselectで必要な要素のみ監視
  final status = ref.watch(
    wordStatusViewModelProvider.select((map) => map[wordId]),
  );
  return status; //?? const WordStatus();
});
