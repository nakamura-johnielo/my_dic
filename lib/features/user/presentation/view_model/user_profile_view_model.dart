import 'package:my_dic/core/shared/utils/logger.dart';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:my_dic/core/shared/enums/ui/button_status.dart';
import 'package:my_dic/core/shared/utils/result.dart';
import 'package:my_dic/features/auth/auth_coordinator.dart';
import 'package:my_dic/features/user/presentation/model/user_profile_ui_model.dart';
import 'package:my_dic/features/user/user_coodinator.dart';

class UserProfileViewModel extends StateNotifier<UserProfileUIState> {
  final AppUserCoordinator _coordinator;
  final AppAuthCoordinator _authCoordinator;

  UserProfileViewModel(this._coordinator, this._authCoordinator)
      : super(UserProfileUIState());

  Future<void> signOut() async {
    final result = await _authCoordinator.signOut();

    result.when(success: (_) {
      AppLogger.print("ログアウトしました");
    }, failure: (error) {
      state = state.copyWith(errorMessage: "ログアウトに失敗しました: ${error.message}");
      AppLogger.print("ログアウトに失敗しました: ${error.message}");
    });
  }

  Future<void> save({String? email, String? username}) async {
    state = state.copyWith(savingButtonStatus: ButtonStatus.waiting);

    final res = await _coordinator.updateUser(
      email: email,
      username: username,
    );

    res.when(success: (_) {
      AppLogger.print("ユーザー情報の更新に成功しました。");
      state = state.copyWith(savingButtonStatus: ButtonStatus.success);
    }, failure: (error) {
      AppLogger.print("ユーザー情報の更新に失敗しました: ${error.message}");
      state = state.copyWith(
          savingButtonStatus: ButtonStatus.error,
          errorMessage: "ユーザー情報の更新に失敗しました: ${error.message}");
    });
  }

//TODO errorの時の再試行
}
