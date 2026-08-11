import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:my_dic/features/user_profile/internal/presentation/view_model/user_profile_view_model.dart';
import 'package:my_dic/features/user_profile/internal/presentation/model/user_profile_ui_model.dart';

import 'package:my_dic/features/user_profile/internal/di/usecase_di.dart';
import 'package:my_dic/core/session/session_scope_key.dart';

final userProfileViewModelProvider = StateNotifierProvider.autoDispose
    .family<UserProfileViewModel, UserProfileUIState, SessionScopeKey>(
        (ref, scope) {
  return UserProfileViewModel(
    scope,
    ref.watch(updateUserInteractorProvider),
  );
});
