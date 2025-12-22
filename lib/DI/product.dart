import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:my_dic/Components/status_buttons.dart';
import 'package:my_dic/core/di/usecase/interactor_di.dart';
import 'package:my_dic/core/domain/entity/word/esp_word.dart';
import 'package:my_dic/_Interface_Adapter/ViewModel/note_view_model.dart';


// ============================================================================
// ViewModel Providers
// ============================================================================

final noteViewModelProvider = ChangeNotifierProvider<NoteViewModel>((ref) {
  return NoteViewModel();
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
