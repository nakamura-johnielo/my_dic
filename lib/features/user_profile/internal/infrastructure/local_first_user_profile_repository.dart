import 'package:uuid/uuid.dart';
import 'package:my_dic/features/sync/port/dataset_contract.dart';
import 'package:my_dic/core/shared/utils/uuid.dart';
import 'package:my_dic/features/user_profile/internal/infrastructure/local/user_device_local_data_source.dart';
import 'package:my_dic/features/user_profile/internal/infrastructure/local/user_profile_local_data_source.dart';
import 'package:my_dic/features/user_profile/internal/infrastructure/local/local_user_dto.dart';
import 'package:my_dic/features/user_profile/port/user_profile.dart';
import 'package:my_dic/features/user_profile/internal/domain/repository/user_profile_repository.dart';

/// App-facing local-first profile repository.
///
/// Editable fields are read from Drift and written atomically with an outbox
/// mutation. Remote provisioning and sync delivery are separate adapters.
final class LocalFirstUserProfileRepository implements UserProfileRepository {
  LocalFirstUserProfileRepository(
      this._local, this._profileLocal, this._outboxWriter,
      {Uuid? uuid})
      : _uuid = uuid ?? const Uuid();

  final UserDeviceLocalDataSource _local;
  final UserProfileLocalDataSource _profileLocal;
  final OutboxWriter _outboxWriter;
  final Uuid _uuid;

  AppError? _handleIdError(AppUser user, String? accountId) {
    if (user.deviceId?.isEmpty ?? true) {
      return DeviceNotFoundError(message: 'Device ID was not found');
    }
    if (accountId?.isEmpty ?? true) {
      return UnauthorizedError(
          message: 'Account ID cannot be empty. Must Login');
    }
    return null;
  }

  Future<String> _getDeviceId() async {
    try {
      final deviceId = (await _local.getUser())?.deviceId;
      if (deviceId != null && deviceId.isNotEmpty) return deviceId;
      final created = MyUUID.generate();
      await _local.updateUser(LocalUserDTO(deviceId: created));
      return created;
    } catch (_) {
      return '';
    }
  }

  @override
  Future<Result<AppUser>> getUserByAccountId(String accountId) async {
    try {
      final deviceId = await _getDeviceId();
      if (deviceId.isEmpty) {
        return Result.failure(
            DeviceNotFoundError(message: 'Device ID was not found'));
      }
      if (await _profileLocal.getProfile(accountId) == null) {
        return Result.failure(UserNotFoundError(message: 'User was not found'));
      }
      return Result.success(AppUser(
        deviceId: deviceId,
        username: await _profileLocal.getUsername(accountId),
      ));
    } catch (e, s) {
      return Result.failure(UnexpectedError(
        message: 'Failed to read the local user profile',
        originalError: e,
        stackTrace: s,
      ));
    }
  }

  @override
  Future<Result<void>> updateUser(AppUser user, String? accountId) =>
      _writeProfile(user, accountId);

  @override
  Future<Result<void>> createNewUser(AppUser user, String? accountId) async {
    final error = _handleIdError(user, accountId);
    if (error != null) return Result.failure(error);
    try {
      await _local.updateUser(LocalUserDTO(deviceId: user.deviceId!));
      return _writeProfile(user, accountId);
    } catch (e, s) {
      return Result.failure(UnexpectedError(
        message: 'Failed to create the local user profile',
        originalError: e,
        stackTrace: s,
      ));
    }
  }

  Future<Result<void>> _writeProfile(AppUser user, String? accountId) async {
    final error = _handleIdError(user, accountId);
    if (error != null) return Result.failure(error);
    try {
      await _profileLocal.runInTransaction(() async {
        final row = await _profileLocal.upsertProfileFields(
          accountId!,
          {'username': user.username},
        );
        await _outboxWriter.enqueue(SyncMutation(
          mutationId: _uuid.v4(),
          accountId: accountId,
          dataset: SyncDataset.userProfile,
          entityId: accountId,
          operation: SyncMutationOperation.upsert,
          payload: {'username': user.username},
          fieldMask: const ['username'],
          localRevision: row.localRevision,
          clientUpdatedAt: DateTime.now().toUtc(),
        ));
      });
      return const Result.success(null);
    } catch (e, s) {
      return Result.failure(UnexpectedError(
        message: 'Failed to update the local user profile',
        originalError: e,
        stackTrace: s,
      ));
    }
  }

  @override
  Future<Result<String>> getThisDeviceId() async {
    final localUser = await _local.getUser();
    if (localUser?.deviceId.isEmpty ?? true) {
      return Result.failure(
          DeviceNotFoundError(message: 'Device ID was not found'));
    }
    return Result.success(localUser!.deviceId);
  }
}
