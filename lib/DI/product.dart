import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:my_dic/Components/status_buttons.dart';
import 'package:my_dic/core/di/data/data_di.dart';
import 'package:my_dic/core/di/usecase/interactor_di.dart';
import 'package:my_dic/core/di/usecase/usecase_di.dart';
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
import 'package:my_dic/_Business_Rule/Usecase/load_rankings/i_load_rankings_use_case.dart';
import 'package:my_dic/_Business_Rule/Usecase/load_rankings/load_rankings_interactor.dart';
import 'package:my_dic/_Business_Rule/Usecase/update_my_word_status/i_update_my_word_status_use_case.dart';
import 'package:my_dic/_Business_Rule/Usecase/update_my_word_status/update_my_word_status_interactor.dart';
import 'package:my_dic/_Business_Rule/Usecase/update_ranking_filter/i_update_ranking_filter_use_case.dart';
import 'package:my_dic/_Business_Rule/Usecase/update_ranking_filter/update_ranking_filter_interactor.dart';
import 'package:my_dic/core/domain/entity/word/esp_word.dart';
import 'package:my_dic/_Business_Rule/_Domain/Repository_I/i_esp_ranking_repository.dart';
import 'package:my_dic/_Business_Rule/_Domain/Repository_I/i_my_word_repository.dart';
import 'package:my_dic/_Framework_Driver/local/drift/DAO/my_word_dao.dart';
import 'package:my_dic/_Framework_Driver/local/drift/DAO/my_word_status_dao.dart';
import 'package:my_dic/_Framework_Driver/local/drift/DAO/ranking_dao.dart';
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
import 'package:my_dic/_Interface_Adapter/Presenter/load_rankings_presenter_impl.dart';
import 'package:my_dic/_Interface_Adapter/Presenter/update_my_word_status_presenter_impl.dart';
import 'package:my_dic/_Interface_Adapter/Presenter/update_ranking_filter_presenter_impl.dart';
import 'package:my_dic/_Interface_Adapter/Presenter/update_status_presenter_impl.dart';
import 'package:my_dic/_Interface_Adapter/ViewModel/jpn_esp_word_page_view_model.dart';
import 'package:my_dic/_Interface_Adapter/ViewModel/main_view_model.dart';
import 'package:my_dic/_Interface_Adapter/ViewModel/my_word_view_model.dart';
import 'package:my_dic/_Interface_Adapter/ViewModel/note_view_model.dart';
import 'package:my_dic/_Interface_Adapter/ViewModel/ranking_view_model.dart';

// ============================================================================
// Database & DAO Providers
// ============================================================================

final rankingDaoProvider = Provider<RankingDao>((ref) {
  return RankingDao(ref.read(databaseProvider));
});

final myWordStatusDaoProvider = Provider<MyWordStatusDao>((ref) {
  return MyWordStatusDao(ref.read(databaseProvider));
});

final myWordDaoProvider = Provider<MyWordDao>((ref) {
  return MyWordDao(ref.read(databaseProvider));
});

// ============================================================================
// Repository Providers
// ============================================================================

final espRankingRepositoryProvider = Provider<IEspRankingRepository>((ref) {
  return WikiEspRankingRepository(ref.read(rankingDaoProvider));
});

final myWordRepositoryProvider = Provider<IMyWordRepository>((ref) {
  return DriftMyWordRepository(
    ref.read(myWordDaoProvider),
    ref.read(myWordStatusDaoProvider),
  );
});

// ============================================================================
// ViewModel Providers
// ============================================================================

final rankingViewModelProvider =
    ChangeNotifierProvider<RankingViewModel>((ref) {
  return RankingViewModel();
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

// ============================================================================
// Other Providers
// ============================================================================

final wordStatusViewModelProvider =
    StateNotifierProvider<WordStatusViewModel, Map<int, WordStatus>>((ref) {
  return WordStatusViewModel(ref.read(espJpnStatusInteractorProvider),
      ref.read(espJpnUpdateInteractorProvider));
});

final wordStatusByIdProvider = Provider.family<WordStatus?, int>((ref, wordId) {
  // 最小限の再ビルドにするためにselectで必要な要素のみ監視
  final status = ref.watch(
    wordStatusViewModelProvider.select((map) => map[wordId]),
  );
  return status; //?? const WordStatus();
});
