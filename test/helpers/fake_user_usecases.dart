/// Fake implementations of user use cases for testing

import 'package:my_dic/core/shared/utils/result.dart';
import 'package:my_dic/features/user/domain/entity/user.dart';
import 'package:my_dic/features/user/domain/usecase/i_ensure_user_exists_use_case.dart';
import 'package:my_dic/features/user/domain/usecase/i_get_user_use_case.dart';
import 'package:my_dic/features/user/domain/usecase/i_update_user_use_case.dart';

/// Fake GetUserInteractor for testing
class FakeGetUserInteractor implements IGetUserUseCase {
  final Result<AppUser>? _executeResult;

  int callCount = 0;
  String? lastId;

  FakeGetUserInteractor({Result<AppUser>? executeResult})
      : _executeResult = executeResult;

  @override
  Future<Result<AppUser>> execute(String id) async {
    callCount++;
    lastId = id;

    return _executeResult ??
        Result.success(AppUser(accountId: id, email: 'test@example.com'));
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
  Future<Result<void>> execute(AppUser user) async {
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

  FakeEnsureUserExistsInteractor({Result<AppUser>? executeResult})
      : _executeResult = executeResult;

  @override
  Future<Result<AppUser>> execute(String id) async {
    callCount++;
    lastId = id;

    return _executeResult ??
        Result.success(AppUser(accountId: id, email: 'test@example.com'));
  }
}
