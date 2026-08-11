import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:my_dic/features/auth/internal/di/usecase_di.dart';
import 'package:my_dic/features/auth/internal/presentation/ui_model/sign_in_model.dart';
import 'package:my_dic/features/auth/internal/presentation/view_model/sign_in_view_model.dart';

final signInViewModelProvider =
    StateNotifierProvider<SignInViewModel, SignInUIState>((ref) {
  return SignInViewModel(ref.watch(resetEmailPasswordInteractorProvider));
});
