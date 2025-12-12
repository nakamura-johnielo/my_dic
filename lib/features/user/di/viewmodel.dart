import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:my_dic/_View/UIModel/user_ui_model.dart';
import 'package:my_dic/features/auth/di/data_di.dart';
import 'package:my_dic/features/user/di/usecase_di.dart';
import 'package:my_dic/features/user/presentation/view_model/user_view_model.dart';

//!TODO refactor depending onuser
final userViewModelProvider =
    StateNotifierProvider<UserViewModel, UserUIModel?>((ref) {
  final getUserInteractor = ref.watch(getUserInteractorProvider);
  final signInInteractor = ref.watch(signInInteractorProvider);
  final signUpInteractor = ref.watch(signUpInteractorProvider);
  final updateUserInteractor = ref.watch(updateUserInteractorProvider);
  final verficateInteractor = ref.watch(verificateInteractorProvider);
  final signOutInteractor = ref.watch(signOutInteractorProvider);
  return UserViewModel(getUserInteractor, updateUserInteractor);
});
