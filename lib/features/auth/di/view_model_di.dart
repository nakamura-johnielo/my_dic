import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:my_dic/features/auth/di/usecase_di.dart';
import 'package:my_dic/features/user/presentation/model/user_ui_model.dart';
import 'package:my_dic/features/auth/presentation/view_model/auth_view_model.dart';

final authViewModelProvider =
    StateNotifierProvider<AuthViewModel, UserState?>((ref) {
  final signInInteractor = ref.watch(signInInteractorProvider);
  final signUpInteractor = ref.watch(signUpInteractorProvider);
  final verficateInteractor = ref.watch(verificateInteractorProvider);
  final signOutInteractor = ref.watch(signOutInteractorProvider);
  return AuthViewModel(signInInteractor, signUpInteractor, verficateInteractor,
      signOutInteractor);
});
