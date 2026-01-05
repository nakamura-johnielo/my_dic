import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:my_dic/features/esp_jpn_word_status/components/status_button/word_status_state.dart';
import 'package:my_dic/features/esp_jpn_word_status/components/status_button/status_buttons_view_model.dart';
import 'package:my_dic/core/di/global.dart';
import 'package:my_dic/core/di/usecase/usecase_di.dart';
import 'package:my_dic/core/section/db_loading/database_loading_notifier.dart';
import 'package:my_dic/core/section/db_loading/database_loading_state.dart';

// final espJpnWordStatusViewModelProvider =
//     StateNotifierProvider<EspJpnWordStatusViewModel, WordStatusState>((ref) {
//   final fetchUsecase = ref.read(fetchEspJpnWordStatusInteractorProvider);
//   final updateUsecase = ref.read(updateStatusUseCaseProvider);
//   return EspJpnWordStatusViewModel(fetchUsecase, updateUsecase);
// });


final databaseLoadingProvider =
    StateNotifierProvider<DatabaseLoadingNotifier, DatabaseLoadingState>(
  (ref) => globalDatabaseLoadingNotifier,
);
