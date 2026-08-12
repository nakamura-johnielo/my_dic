import 'dart:convert';

import 'package:my_dic/features/user_profile/internal/infrastructure/local/i_user_profile_local_data_source.dart';
import 'package:my_dic/features/user_profile/port/live_user_profile.dart';
import 'package:my_dic/features/user_profile/port/user_profile.dart';

final class LiveUserProfileAdapter implements LiveUserProfilePort {
  LiveUserProfileAdapter(this._local);

  final IUserProfileLocalDataSource _local;

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
