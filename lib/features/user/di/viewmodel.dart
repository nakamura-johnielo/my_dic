import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:my_dic/core/di/coordinator/corrdinator.dart';
import 'package:my_dic/features/auth/di/service.dart';
import 'package:my_dic/features/auth/di/view_model_di.dart';
import 'package:my_dic/features/user/di/service.dart';
import 'package:my_dic/features/user/presentation/view_model/user_profile_view_model.dart';
import 'package:my_dic/features/user/presentation/model/user_profile_ui_model.dart';

import 'package:my_dic/features/user/di/usecase_di.dart';
import 'package:my_dic/features/user/user_coodinator.dart';

// final userViewModelProvider =
//     StateNotifierProvider<UserViewModel, UserProfileUIState>((ref) {
//   final service = ref.watch(userServiceProvider);
//   final authService = ref.watch(authServiceProvider);
//   return UserViewModel(service, authService);
// });

// final userViewModelProviderLegacy =
//     StateNotifierProvider<UserViewModel, UserProfileUIState>((ref) {
//   final service = ref.watch(userServiceProvider);
//   return UserViewModel(service, authService);
// });


final appUserCoordinatorProvider=Provider<AppUserCoordinator>((ref){
  final getUserInteractor = ref.watch(getUserInteractorProvider);
  final createUserUsecase = ref.watch(createNewUserInteractorProvider);
  final updateUserInteractor = ref.watch(updateUserInteractorProvider);
  final ensureUserExistsInteractor =
      ref.watch(ensureUserExistsInteractorProvider);
  return AppUserCoordinator(getUserInteractor, updateUserInteractor,
      ensureUserExistsInteractor, createUserUsecase, ref);
});

final userProfileViewModelProvider = 
    StateNotifierProvider<UserProfileViewModel, UserProfileUIState>((ref) {
  // final getUserInteractor = ref.watch(getUserInteractorProvider);
  // final createUserUsecase = ref.watch(createNewUserInteractorProvider);
  // final updateUserInteractor = ref.watch(updateUserInteractorProvider);
  // final ensureUserExistsInteractor =
  //     ref.watch(ensureUserExistsInteractorProvider);
  final coordinator = ref.watch(appUserCoordinatorProvider);
  final authCoordinator=ref.watch(authCoordinatorProvider);
  return UserProfileViewModel(coordinator, authCoordinator);
});