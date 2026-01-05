import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:my_dic/core/shared/errors/domain_errors.dart';
import 'package:my_dic/core/shared/utils/result.dart';
import 'package:my_dic/features/auth/auth_coordinator.dart';
import 'package:my_dic/features/auth/di/service.dart';
import 'package:my_dic/features/auth/domain/entity/app_auth.dart';
import 'package:my_dic/features/user/di/service.dart';
import 'package:my_dic/features/user/domain/entity/user.dart';
import 'package:my_dic/features/user/user_coodinator.dart';

class AuthUserCoordinator {
  final AppAuthCoordinator auth;
  final AppUserCoordinator user;
  final Ref ref;

  AppAuth? get _authStore => ref.read(authStoreNotifierProvider);
  AppUser? get _userStore => ref.read(appUserStoreNotifierProvider);

  AuthUserCoordinator(
      {required this.auth, required this.user, required this.ref});
  // UI が呼ぶ高レベルAPIだけ置く
  Future<Result<AppAuth>> signIn(String email, String pw) async {
    print("sign in crd======================================");
    final res = await auth.signIn(email, pw);
    return await res.when(
      success: (appAuth) async {
        print("auth.signIn success ======================================");
        final result = await refreshUser(appAuth.accountId);
        return await result.when(
          success: (_) => Result.success(appAuth),
          failure: (error) async {
            if (error is UnauthorizedError) {
              final userres = await auth.verifyEmail();
             return userres.when(
                  success: (_) => Result.failure(UnauthorizedError(
                      message: "承認メールを送りました")),
                  failure: (error) =>Result.failure(error));
            }
            return Result.failure(error);
          },
        );
      },
      failure: (error) async {
        if (error is UnauthorizedError) {
          final userres = await auth.verifyEmail();
          userres.when(
              success: (_) => print(
                  "AuthUserCoordinator signIn verifyEmail success ===================="),
              failure: (error) => print(
                  "AuthUserCoordinator signIn error ===================="));
        }
        if (error is NotFoundError ||
            error is UserNotFoundError ||
            error is DeviceNotFoundError) {
          final userres = await createUser();
          userres.when(
              success: (_) => print(
                  "AuthUserCoordinator signIn createUser success ===================="),
              failure: (error) => print(
                  "AuthUserCoordinator signIn error ===================="));
        }
        return Result.failure(error);
      },
    );
  }

  //TODO watchの時に
  //TODO 変更するためのAPI
  Future<Result<void>> updateAuth(AppAuth appAuth) async {
    final res = auth.setAuth(appAuth);

    return res.map((_) async {
      await refreshUser(appAuth.accountId);
    });
  }

  Future<Result<AppAuth>> signUp(String email, String pw) async {
    final res = await auth.signUp(email, pw);
    return await res.when(
      success: (appAuth) async {
        if (appAuth.isAuthenticated) {
          print("AuthUserCoordinator signUp: User is already authenticated.");
          final result = await createUser();
          return await result.when(
            success: (_) => Result.success(appAuth),
            failure: (error) => Result.failure(error),
          );
        }

        final userres = await auth.verifyEmail();
        return userres.when(
            success: (_) => Result.success(appAuth),
            failure: (error) => Result.failure(error));

        //return Result.success(appAuth);
      },
      failure: (error) => Result.failure(error),
    );
  }

  Future<Result<void>> signOut() async {
    final res = await auth.signOut();
    return res.map((_) {
      user.clear();
    });
  }

  Future<Result<void>> refreshUser(String accountId) async {
    //getUserして、なければcreateUserする

    print("refreshUser=============");
    if (_authStore?.isAuthenticated ?? false) {
      print("ユーザー情報をリフレッシュします。");
      final res = await user.fetchUser(accountId);
      return res.when(
          success: (_) => Result.success(null),
          failure: (failure) async {
            if (failure is UserNotFoundError ||
                failure is DeviceNotFoundError ||
                failure is NotFoundError) {
              print("ユーザー新規制作: ${failure.message}");
              return await createUser();
            }
            return Result.failure(failure);
          });
    } else {}
    print("refreshUser ----FAIL=============");
    return Result.failure(UnauthorizedError(message: "ユーザーが認証されていません。"));
  }

  Future<Result<void>> createUser() async {
    final authInfo = _authStore;
    if (authInfo == null) {
      return Result.failure(NotFoundError(message: "ログインしていません。"));
    }

    if (!authInfo.isAuthenticated) {
      return Result.failure(UnauthorizedError(message: "ユーザーが認証されていません。"));
    }

    final appUser = AppUser(
      accountId: authInfo.accountId,
      email: authInfo.email,
    );
    return user.createUser(appUser);
  }
}
