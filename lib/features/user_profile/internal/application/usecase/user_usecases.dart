import 'package:my_dic/core/shared/errors/domain_errors.dart';
import 'package:my_dic/core/shared/utils/result.dart';
import 'package:my_dic/core/shared/utils/uuid.dart';
import 'package:my_dic/features/user_profile/port/user_profile.dart';
import 'package:my_dic/features/user_profile/internal/domain/i_repository/i_user_repository.dart';
import 'package:my_dic/features/user_profile/internal/domain/i_repository/i_user_profile_provisioner.dart';
import 'package:my_dic/features/user_profile/port/auth_lifecycle.dart';

abstract interface class IGetUserUseCase {
  Future<Result<AppUser>> execute(String accountId);
}

abstract interface class ICreateNewUserUseCase {
  Future<Result<AppUser>> execute(AppUser appUser, String accountId);
}

abstract interface class IUpdateUserUseCase implements UpdateUserProfilePort {
  Future<Result<void>> execute(AppUser user, String accountId);

  @override
  Future<Result<void>> updateUser(AppUser user, String accountId) =>
      execute(user, accountId);
}

abstract interface class IEnsureUserExistsUseCase
    implements EnsureUserProfilePort {
  Future<Result<AppUser>> execute(String id, {String? email});

  @override
  Future<Result<AppUser>> ensureUserProfile(String accountId,
          {String? email}) =>
      execute(accountId, email: email);
}

/// Resolves the signed-in account in the application layer before reading a
/// profile. Domain remains limited to the profile entity and repository port.
class GetUserInteractor implements IGetUserUseCase {
  GetUserInteractor(this._repository);
  final IUserRepository _repository;

  @override
  Future<Result<AppUser>> execute(String accountId) {
    if (accountId.isEmpty) {
      return Future.value(Result.failure(
        NotFoundError(message: 'User is not authenticated'),
      ));
    }
    return _repository.getUserByAccountId(accountId);
  }
}

/// Creates a local profile only for the current authenticated account.
/// Device-ID lookup and the default display name are application concerns.
class CreateNewUserInteractor implements ICreateNewUserUseCase {
  CreateNewUserInteractor(this._repository);
  final IUserRepository _repository;

  @override
  Future<Result<AppUser>> execute(AppUser appUser, String accountId) async {
    if (accountId.isEmpty) {
      return Result.failure(
        UnauthorizedError(message: 'Account ID cannot be empty. Must Login'),
      );
    }

    final existing = await _repository.getUserByAccountId(accountId);
    return existing.when(
      success: Result.success,
      failure: (error) async {
        if (error is! UserNotFoundError) return Result.failure(error);
        final deviceResult = await _repository.getThisDeviceId();
        final deviceId = deviceResult.dataOrNull ?? MyUUID.generate();
        final email = appUser.email;
        final user = appUser.copyWith(
          deviceId: deviceId,
          username: email == null ? null : _usernameFromEmail(email),
        );
        final created = await _repository.createNewUser(user, accountId);
        return created.when(
          success: (_) => Result.success(user),
          failure: Result.failure,
        );
      },
    );
  }

  String _usernameFromEmail(String email) {
    final atIndex = email.indexOf('@');
    return atIndex == -1 ? email : email.substring(0, atIndex);
  }
}

class UpdateUserInteractor implements IUpdateUserUseCase {
  UpdateUserInteractor(this._repository);
  final IUserRepository _repository;

  @override
  Future<Result<void>> execute(AppUser user, String accountId) =>
      _repository.updateUser(user, accountId);

  @override
  Future<Result<void>> updateUser(AppUser user, String accountId) =>
      execute(user, accountId);
}

/// Lifecycle profile provisioning. The authenticated identity is supplied by
/// the lifecycle controller, while persistence stays behind the domain port.
class EnsureUserExistsInteractor implements IEnsureUserExistsUseCase {
  EnsureUserExistsInteractor(this._provisioner);
  final IUserProfileProvisioner _provisioner;

  @override
  Future<Result<AppUser>> execute(String id, {String? email}) =>
      _provisioner.ensureUserProfile(accountId: id, email: email);

  @override
  Future<Result<AppUser>> ensureUserProfile(String accountId,
          {String? email}) =>
      execute(accountId, email: email);
}
