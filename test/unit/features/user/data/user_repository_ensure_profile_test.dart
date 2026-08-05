import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:my_dic/features/user/data/data_source/local/i_user_local_data_source.dart';
import 'package:my_dic/features/user/data/data_source/remote/i_user_remote_data_source.dart';
import 'package:my_dic/features/user/data/dto/local_user_dto.dart';
import 'package:my_dic/features/user/data/dto/user_dto.dart';
import 'package:my_dic/features/user/data/repository_impl/user_repository.dart';

class _MockRemote extends Mock implements IUserRemoteDataSource {}

class _MockLocal extends Mock implements IUserLocalDataSource {}

void main() {
  late _MockRemote remote;
  late _MockLocal local;
  late UserRepository repository;

  setUpAll(() {
    registerFallbackValue(UserDTO(userId: 'fallback'));
  });

  setUp(() {
    remote = _MockRemote();
    local = _MockLocal();
    repository = UserRepository(remote, local);
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
}
