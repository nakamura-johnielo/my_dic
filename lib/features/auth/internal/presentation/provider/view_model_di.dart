import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:my_dic/features/auth/internal/presentation/ui_model/sign_in_model.dart';
import 'package:my_dic/features/auth/internal/presentation/view_model/sign_in_view_model.dart';
import 'package:my_dic/features/auth/port/command.dart';

final signInViewModelProvider = StateNotifierProvider.autoDispose
    .family<SignInViewModel, SignInUIState, AuthCommandPort>((ref, commands) {
  return SignInViewModel(commands);
});
