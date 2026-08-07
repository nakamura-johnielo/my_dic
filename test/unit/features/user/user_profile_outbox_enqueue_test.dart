import 'dart:convert';

import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:my_dic/core/infrastructure/database/drift/database_provider.dart';
import 'package:my_dic/core/shared/errors/domain_errors.dart';
import 'package:my_dic/features/sync/infrastructure/persistence/drift/drift_outbox_writer.dart';
import 'package:my_dic/features/user/data/data_source/local/drift_user_profile_dao.dart';
import 'package:my_dic/features/user/data/data_source/local/i_user_local_data_source.dart';
import 'package:my_dic/features/user/data/data_source/local/user_profile_drift_data_source.dart';
import 'package:my_dic/features/user/data/dto/local_user_dto.dart';
import 'package:my_dic/features/user/data/repository_impl/user_repository.dart';
import 'package:my_dic/features/user/domain/entity/user.dart';

class _FakeUserLocalDataSource implements IUserLocalDataSource {
  LocalUserDTO? _stored = LocalUserDTO(deviceId: 'device-a');

  @override
  Future<LocalUserDTO?> getUser() async => _stored;

  @override
  Future<void> updateUser(LocalUserDTO user) async {
    _stored = user;
  }
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late DatabaseProvider database;
  late UserRepository repository;

  setUp(() {
    database = DatabaseProvider.forTesting(NativeDatabase.memory());
    final profileLocal = UserProfileDriftDataSource(UserProfileDao(database));
    final writer = DriftOutboxWriter(database, clock: () => DateTime.utc(2026));
    repository = UserRepository(
      _FakeUserLocalDataSource(),
      profileLocal,
      writer,
    );
  });

  tearDown(() => database.close());

  group('User profile outbox enqueue on local write', () {
    test('signed-in updateUser enqueues one upsert mutation for username',
        () async {
      final result = await repository.updateUser(
        AppUser(deviceId: 'device-a', username: 'Taro'),
        'account-a',
      );
      expect(result.isSuccess, isTrue);

      final rows = await database.select(database.syncOutbox).get();
      expect(rows, hasLength(1));
      final row = rows.single;
      expect(row.accountId, 'account-a');
      expect(row.dataset, 'user_profile');
      expect(row.entityId, 'account-a');
      expect(row.operation, 'upsert');
      expect(jsonDecode(row.fieldMask), ['username']);
      expect(jsonDecode(row.payload), {'username': 'Taro'});
      expect(row.localRevision, 1);

      final profileRows = await database.select(database.userProfiles).get();
      expect(profileRows, hasLength(1));
      expect(jsonDecode(profileRows.single.payload), {'username': 'Taro'});
    });

    test('missing accountId fails without enqueueing an outbox mutation',
        () async {
      final result = await repository.updateUser(
        AppUser(deviceId: 'device-a', username: 'Taro'),
        null,
      );
      expect(result.isFailure, isTrue);
      expect(result.errorOrNull, isA<UnauthorizedError>());
      expect(await database.select(database.syncOutbox).get(), isEmpty);
    });

    test('createNewUser persists the profile locally and enqueues its write',
        () async {
      final result = await repository.createNewUser(
        AppUser(deviceId: 'device-created', username: 'Hanako'),
        'account-created',
      );

      expect(result.isSuccess, isTrue);
      final profile = await database.select(database.userProfiles).getSingle();
      expect(profile.accountId, 'account-created');
      expect(jsonDecode(profile.payload), {'username': 'Hanako'});

      final mutation = await database.select(database.syncOutbox).getSingle();
      expect(mutation.accountId, 'account-created');
      expect(jsonDecode(mutation.payload), {'username': 'Hanako'});
    });

    test(
        'repeated updateUser coalesces into a single mutation and advances '
        'the profile revision', () async {
      await repository.updateUser(
          AppUser(deviceId: 'device-a', username: 'Taro'), 'account-a');
      final result = await repository.updateUser(
          AppUser(deviceId: 'device-a', username: 'Jiro'), 'account-a');
      expect(result.isSuccess, isTrue);

      final rows = await database.select(database.syncOutbox).get();
      expect(rows, hasLength(1));
      expect(jsonDecode(rows.single.payload), {'username': 'Jiro'});

      final profileRows = await database.select(database.userProfiles).get();
      expect(profileRows.single.localRevision, 2);
    });
  });
}
