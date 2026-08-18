import 'package:my_dic/core/shared/utils/result.dart';
import 'package:my_dic/features/user_profile/port/user_profile.dart';

final class FakeUpdateUserProfileCommands implements UserProfileCommandPort {
  FakeUpdateUserProfileCommands({Result<void>? executeResult})
      : _updateResult = executeResult;

  final Result<void>? _updateResult;
  int callCount = 0;
  AppUser? lastUser;

  @override
  Future<Result<void>> updateUser(AppUser user, String accountId) async {
    callCount++;
    lastUser = user;
    return _updateResult ?? const Result.success(null);
  }

  @override
  Future<Result<AppUser>> ensureUserProfile(
    String accountId, {
    String? email,
  }) async =>
      Result.success(AppUser(deviceId: 'device-1', email: email));
}

final class FakeEnsureUserProfileCommands implements UserProfileCommandPort {
  FakeEnsureUserProfileCommands({Result<AppUser>? executeResult})
      : _ensureResult = executeResult;

  final Result<AppUser>? _ensureResult;
  int callCount = 0;
  String? lastId;
  String? lastEmail;

  @override
  Future<Result<AppUser>> ensureUserProfile(
    String accountId, {
    String? email,
  }) async {
    callCount++;
    lastId = accountId;
    lastEmail = email;
    return _ensureResult ??
        Result.success(AppUser(deviceId: 'device-1', email: email));
  }

  @override
  Future<Result<void>> updateUser(AppUser user, String accountId) async =>
      const Result.success(null);
}
