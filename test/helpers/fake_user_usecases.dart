// Fake implementations of user use cases for testing.

import 'package:my_dic/core/shared/utils/result.dart';
import 'package:my_dic/features/user_profile/domain/entity/user.dart';
import 'package:my_dic/features/user_profile/application/usecase/user_usecases.dart';

/// Fake GetUserInteractor for testing
class FakeGetUserInteractor implements IGetUserUseCase {
  final Result<AppUser>? _executeResult;

  int callCount = 0;
  FakeGetUserInteractor({Result<AppUser>? executeResult})
      : _executeResult = executeResult;

  @override
  Future<Result<AppUser>> execute(String accountId) async {
    callCount++;

    return _executeResult ??
        Result.success(
            AppUser(deviceId: 'device-1', email: 'test@example.com'));
  }
}

/// Fake UpdateUserInteractor for testing
class FakeUpdateUserInteractor implements IUpdateUserUseCase {
  final Result<void>? _executeResult;

  int callCount = 0;
  AppUser? lastUser;

  FakeUpdateUserInteractor({Result<void>? executeResult})
      : _executeResult = executeResult;

  @override
  Future<Result<void>> execute(AppUser user, String accountId) async {
    callCount++;
    lastUser = user;

    return _executeResult ?? const Result.success(null);
  }
}

/// Fake EnsureUserExistsInteractor for testing
class FakeEnsureUserExistsInteractor implements IEnsureUserExistsUseCase {
  final Result<AppUser>? _executeResult;

  int callCount = 0;
  String? lastId;
  String? lastEmail;

  FakeEnsureUserExistsInteractor({Result<AppUser>? executeResult})
      : _executeResult = executeResult;

  @override
  Future<Result<AppUser>> execute(String id, {String? email}) async {
    callCount++;
    lastId = id;
    lastEmail = email;

    return _executeResult ??
        Result.success(AppUser(deviceId: 'device-1', email: email));
  }

  @override
  Future<Result<AppUser>> ensureUserProfile(String accountId, {String? email}) =>
      execute(accountId, email: email);
}
