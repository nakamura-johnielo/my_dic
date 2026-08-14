import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:my_dic/features/user_profile/internal/infrastructure/local/user_device_local_data_source.dart';
import 'package:my_dic/features/user_profile/internal/infrastructure/local/user_profile_local_data_source.dart';
import 'package:my_dic/features/user_profile/internal/infrastructure/firebase/user_profile_remote_data_source.dart';
import 'package:my_dic/features/user_profile/internal/infrastructure/firebase/user_profile_remote_dto.dart';
import 'package:my_dic/features/user_profile/internal/infrastructure/local/local_user_dto.dart';
import 'package:my_dic/features/user_profile/internal/infrastructure/user_profile_provisioning_service.dart';

class _MockRemote extends Mock implements UserProfileRemoteDataSource {}

class _MockLocal extends Mock implements UserDeviceLocalDataSource {}

class _MockUserProfileLocal extends Mock
    implements UserProfileLocalDataSource {}

void main() {
  late _MockRemote remote;
  late _MockLocal local;
  late _MockUserProfileLocal profileLocal;
  late UserProfileProvisioningService repository;

  setUpAll(() {
    registerFallbackValue(UserProfileRemoteDto(userId: 'fallback'));
  });

  setUp(() {
    remote = _MockRemote();
    local = _MockLocal();
    profileLocal = _MockUserProfileLocal();
    repository = UserProfileProvisioningService(
      remote,
      local,
      profileLocal,
    );
    when(() => local.getUser()).thenAnswer(
      (_) async => LocalUserDTO(deviceId: 'device-1'),
    );
    when(() => remote.ensureUser(any())).thenAnswer(
      (_) async => UserProfileRemoteDto(
        userId: 'account-1',
        email: 'person@example.com',
        userName: 'Existing Name',
      ),
    );
    when(() => profileLocal.getUsername(any())).thenAnswer((_) async => null);
    when(() => profileLocal.applyRemoteFields(any(),
        username: any(named: 'username'))).thenAnswer((_) async {});
  });

  test('repeated provisioning uses only the idempotent ensure operation',
      () async {
    final first = await repository.ensureUserProfile(
      accountId: 'account-1',
      email: 'person@example.com',
    );
    final second = await repository.ensureUserProfile(
      accountId: 'account-1',
      email: 'person@example.com',
    );

    expect(first.isSuccess, isTrue);
    expect(second.isSuccess, isTrue);
    expect(second.dataOrNull?.username, 'Existing Name');

    final captured =
        verify(() => remote.ensureUser(captureAny()))
            .captured
            .cast<UserProfileRemoteDto>();
    expect(captured, hasLength(2));
    expect(captured.every((dto) => dto.userId == 'account-1'), isTrue);
    verifyNever(() => remote.createUser(any()));
    verifyNever(() => remote.updateUser(any()));
  });

  test('an existing local Drift username overrides the remote baseline',
      () async {
    when(() => profileLocal.getUsername('account-1'))
        .thenAnswer((_) async => 'Locally Edited Name');

    final result = await repository.ensureUserProfile(
      accountId: 'account-1',
      email: 'person@example.com',
    );

    expect(result.dataOrNull?.username, 'Locally Edited Name');
    verifyNever(() => profileLocal.applyRemoteFields(any(),
        username: any(named: 'username')));
  });
}
