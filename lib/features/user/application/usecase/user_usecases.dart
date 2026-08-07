import 'package:my_dic/app/session/current_session.dart';
import 'package:my_dic/core/shared/errors/domain_errors.dart';
import 'package:my_dic/core/shared/utils/result.dart';
import 'package:my_dic/core/shared/utils/uuid.dart';
import 'package:my_dic/features/user/domain/entity/user.dart';
import 'package:my_dic/features/user/domain/i_repository/i_user_repository.dart';

abstract interface class IGetUserUseCase {
  Future<Result<AppUser>> execute();
}

abstract interface class ICreateNewUserUseCase {
  Future<Result<AppUser>> execute(AppUser appUser);
}

abstract interface class IUpdateUserUseCase {
  Future<Result<void>> execute(AppUser user);
}

abstract interface class IEnsureUserExistsUseCase {
  Future<Result<AppUser>> execute(String id, {String? email});
}

/// Resolves the signed-in account in the application layer before reading a
/// profile. Domain remains limited to the profile entity and repository port.
class GetUserInteractor implements IGetUserUseCase {
  GetUserInteractor(this._repository, this._session);
  final IUserRepository _repository;
  final CurrentSession _session;

  @override
  Future<Result<AppUser>> execute() {
    final accountId = _session.accountIdOrNull;
    if (accountId == null || accountId.isEmpty) {
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
  CreateNewUserInteractor(this._repository, this._session);
  final IUserRepository _repository;
  final CurrentSession _session;

  @override
  Future<Result<AppUser>> execute(AppUser appUser) async {
    final accountId = _session.accountIdOrNull;
    if (accountId == null) {
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
  UpdateUserInteractor(this._repository, this._session);
  final IUserRepository _repository;
  final CurrentSession _session;

  @override
  Future<Result<void>> execute(AppUser user) =>
      _repository.updateUser(user, _session.accountIdOrNull);
}

/// Lifecycle profile provisioning. The authenticated identity is supplied by
/// the lifecycle controller, while persistence stays behind the domain port.
class EnsureUserExistsInteractor implements IEnsureUserExistsUseCase {
  EnsureUserExistsInteractor(this._repository);
  final IUserRepository _repository;

  @override
  Future<Result<AppUser>> execute(String id, {String? email}) =>
      _repository.ensureUserProfile(accountId: id, email: email);
}
