import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:my_dic/features/auth/di/service.dart';
import 'package:my_dic/features/user/di/service.dart';
import 'package:my_dic/features/user/presentation/model/user_ui_model.dart';
import 'package:my_dic/features/user/presentation/view_model/user_view_model.dart';


// final userViewModelProvider =
//     StateNotifierProvider<UserViewModel, UserProfileUIState>((ref) {
//   final service = ref.watch(userServiceProvider);
//   final authService = ref.watch(authServiceProvider);
//   return UserViewModel(service, authService);
// });

final userViewModelProvider =
    StateNotifierProvider<UserViewModel, UserProfileUIState>((ref) {
  final service = ref.watch(userServiceProvider);
  final authService = ref.watch(authServiceProvider);
  return UserViewModel(service, authService);
});

