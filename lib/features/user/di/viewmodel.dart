import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:my_dic/features/user/presentation/view_model/user_profile_view_model.dart';
import 'package:my_dic/features/user/presentation/model/user_profile_ui_model.dart';

import 'package:my_dic/features/user/di/usecase_di.dart';

final userProfileViewModelProvider =
    StateNotifierProvider<UserProfileViewModel, UserProfileUIState>((ref) {
  return UserProfileViewModel(ref.watch(updateUserInteractorProvider));
});
