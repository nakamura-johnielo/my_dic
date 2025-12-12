import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:my_dic/_View/UIModel/user_ui_model.dart';
import 'package:my_dic/features/user/di/usecase_di.dart';
import 'package:my_dic/features/user/presentation/view_model/user_view_model.dart';

final userViewModelProvider =
    StateNotifierProvider<UserViewModel, UserUIModel?>((ref) {
  final getUserInteractor = ref.watch(getUserInteractorProvider);
  final updateUserInteractor = ref.watch(updateUserInteractorProvider);
  return UserViewModel(getUserInteractor, updateUserInteractor);
});
