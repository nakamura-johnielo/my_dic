import 'dart:convert';

import 'package:my_dic/features/user_profile/internal/infrastructure/local/user_profile_local_data_source.dart';
import 'package:my_dic/features/user_profile/port/user_profile.dart';

final class LocalUserProfileQueryService implements UserProfileQueryPort {
  LocalUserProfileQueryService(this._local);

  final UserProfileLocalDataSource _local;

  @override
  Stream<AppUser?> watchProfile(String accountId) =>
      _local.watchProfile(accountId).map((row) {
        if (row == null) return null;
        final payload = Map<String, Object?>.from(
          jsonDecode(row.payload) as Map,
        );
        final username = payload['username'];
        return AppUser(username: username is String ? username : null);
      });
}
