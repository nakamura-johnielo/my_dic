import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:my_dic/features/sync/application/port/outbox_writer.dart';
import 'package:my_dic/features/user/data/data_source/local/i_user_local_data_source.dart';
import 'package:my_dic/features/user/data/data_source/local/i_user_profile_local_data_source.dart';
import 'package:my_dic/features/user/data/data_source/remote/i_user_remote_data_source.dart';
import 'package:my_dic/features/user/data/dto/local_user_dto.dart';
import 'package:my_dic/features/user/data/dto/user_dto.dart';
import 'package:my_dic/features/user/data/repository_impl/user_repository.dart';

class _MockRemote extends Mock implements IUserRemoteDataSource {}

class _MockLocal extends Mock implements IUserLocalDataSource {}

class _MockUserProfileLocal extends Mock
    implements IUserProfileLocalDataSource {}

class _MockOutboxWriter extends Mock implements OutboxWriter {}

void main() {
  late _MockRemote remote;
  late _MockLocal local;
  late _MockUserProfileLocal profileLocal;
  late UserRepository repository;

  setUpAll(() {
    registerFallbackValue(UserDTO(userId: 'fallback'));
  });

  setUp(() {
    remote = _MockRemote();
    local = _MockLocal();
    profileLocal = _MockUserProfileLocal();
    repository = UserRepository(
      remote,
      local,
      profileLocal,
      _MockOutboxWriter(),
    );
    when(() => local.getUser()).thenAnswer(
      (_) async => LocalUserDTO(deviceId: 'device-1'),
    );
    when(() => remote.ensureUser(any())).thenAnswer(
      (_) async => UserDTO(
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
        verify(() => remote.ensureUser(captureAny())).captured.cast<UserDTO>();
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
