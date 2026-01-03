import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:my_dic/features/auth/di/service.dart';
import 'package:my_dic/features/auth/di/usecase_di.dart';
import 'package:my_dic/features/auth/domain/usecase/send_email_interactor.dart';
import 'package:my_dic/features/auth/presentation/ui_model/sign_in_model.dart';
import 'package:my_dic/features/auth/presentation/view_model/sign_in_view_model.dart';
import 'package:my_dic/features/user/presentation/model/user_ui_model.dart';
import 'package:my_dic/features/auth/presentation/view_model/auth_view_model.dart';

// final authViewModelProvider =
//     StateNotifierProvider<AuthViewModel, UserState?>((ref) {
//   final signInInteractor = ref.watch(signInInteractorProvider);
//   final signUpInteractor = ref.watch(signUpInteractorProvider);
//   final verficateInteractor = ref.watch(verificateInteractorProvider);
//   final signOutInteractor = ref.watch(signOutInteractorProvider);
//   final resetEmailPasswordInteractor =
//       ref.watch(resetEmailPasswordInteractorProvider);
//   return AuthViewModel(signInInteractor, signUpInteractor, verficateInteractor,
//       signOutInteractor,resetEmailPasswordInteractor);
// });


final signInViewModelProvider=StateNotifierProvider<SignInViewModel, SignInUIState>((ref) {
  final authService=ref.watch(authServiceProvider);
  return SignInViewModel(authService);
});