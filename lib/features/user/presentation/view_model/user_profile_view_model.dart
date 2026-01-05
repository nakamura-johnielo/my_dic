import 'dart:developer';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:my_dic/core/application/coordinator/auth_user_coordinator.dart';
import 'package:my_dic/core/shared/enums/auth/subscription_status.dart';
import 'package:my_dic/core/shared/enums/ui/button_status.dart';
import 'package:my_dic/core/shared/errors/domain_errors.dart';
import 'package:my_dic/core/shared/utils/result.dart';
import 'package:my_dic/features/auth/auth_coordinator.dart';
import 'package:my_dic/features/auth/di/service.dart';
import 'package:my_dic/features/auth/presentation/view_model/auth_store.dart';
import 'package:my_dic/features/user/di/service.dart';
import 'package:my_dic/features/user/domain/usecase/i_create_new_user_use_case.dart';
import 'package:my_dic/features/user/domain/usecase/i_ensure_user_exists_use_case.dart';
import 'package:my_dic/features/user/domain/usecase/i_get_user_use_case.dart';
import 'package:my_dic/core/domain/entity/auth.dart';
import 'package:my_dic/features/user/domain/entity/user.dart';
import 'package:my_dic/features/user/domain/usecase/i_update_user_use_case.dart';
import 'package:my_dic/features/user/presentation/model/user_profile_ui_model.dart';
import 'package:my_dic/features/user/presentation/view_model/app_user_store.dart';
import 'package:my_dic/features/user/user_coodinator.dart';

class UserProfileViewModel extends StateNotifier<UserProfileUIState> {
  //TODO こっちが本物
  // final IGetUserUseCase _getUserInteractor;
  // final IUpdateUserUseCase _updateUserInteractor;
  // final IEnsureUserExistsUseCase _ensureUserExistsInteractor;
  // final ICreateNewUserUseCase _createNewUserInteractor;
  //final Ref ref;
  final AppUserCoordinator _coordinator;
  final AuthUserCoordinator _authUserCoordinator;

  // AppUser? get _userStore => ref.read(appUserStoreNotifierProvider);
  // AppUserStoreNotifier get _storeNotifier =>
  //     ref.read(appUserStoreNotifierProvider.notifier);

  UserProfileViewModel(
      // this._getUserInteractor,
      // this._updateUserInteractor,
      // this._ensureUserExistsInteractor,
      // this._createNewUserInteractor,
      this._coordinator, this._authUserCoordinator)
      : super(UserProfileUIState());
  Future<void> signOut() async {
    // state = state.copyWith(: ButtonStatus.waiting);

    final result = await _authUserCoordinator.signOut();

    result.when(success: (_) {
      // state = state.copyWith(signOutButtonStatus: ButtonStatus.success);
      log("ログアウトしました");
    }, failure: (error) {
      state = state.copyWith(errorMessage:  "ログアウトに失敗しました: ${error.message}");
      log("ログアウトに失敗しました: ${error.message}");
    });
  }

  Future<void> save({String? email, String? username}) async {
    state = state.copyWith(savingButtonStatus: ButtonStatus.waiting);

    final res = await _coordinator.updateUser(
      email: email,
      username: username,
    );

    res.when(success: (_) {
      log("ユーザー情報の更新に成功しました。");
      state = state.copyWith(savingButtonStatus: ButtonStatus.success);
    }, failure: (error) {
      log("ユーザー情報の更新に失敗しました: ${error.message}");
      state = state.copyWith(
          savingButtonStatus: ButtonStatus.error,
          errorMessage: "ユーザー情報の更新に失敗しました: ${error.message}");
    });
  }

//TODO errorの時の再試行

  // Future<void> createUser(AppUser user) async {
  //   final res = await _coordinator.createUser();
  //   res.when(success: (_) {
  //     log("ユーザー作成に成功しました。");
  //   }, failure: (error) {
  //     log("ユーザー作成に失敗しました: ${error.message}");
  //     state = state.copyWith(savingButtonStatus: ButtonStatus.error);
  //   });
  // }

  // Future<void> refreshUser() async {
  //   final res = await _coordinator.refreshUser();

  //   res.when(success: (_) {
  //     log("ユーザー再取得に成功しました。");
  //   }, failure: (error) {
  //     log("ユーザー情報の更新に失敗しました: ${error.message}");
  //     state =
  //         state.copyWith(errorMessage: "ユーザー情報の更新に失敗しました: ${error.message}");
  //   });
  // }
}
