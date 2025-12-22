import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:my_dic/features/my_word/di/usecase_di.dart';
import 'package:my_dic/features/my_word/presentation/view_model/my_word_controller.dart';
import 'package:my_dic/features/my_word/presentation/load_my_word_presenter_impl.dart';
import 'package:my_dic/features/my_word/presentation/my_word_fragment_presenter_impl.dart';
import 'package:my_dic/features/my_word/presentation/update_my_word_status_presenter_impl.dart';
import 'package:my_dic/features/my_word/presentation/view_model/my_word_view_model.dart';



// ============================================================================
// Presenter Providers
// ============================================================================

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
// ViewModel Providers
// ============================================================================


final myWordViewModelProvider = ChangeNotifierProvider<MyWordViewModel>((ref) {
  return MyWordViewModel();
});


// ============================================================================
// Controller Providers
// ============================================================================

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
