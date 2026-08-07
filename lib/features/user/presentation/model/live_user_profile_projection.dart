import 'dart:convert';

import 'package:my_dic/core/infrastructure/database/drift/database_provider.dart'
    as db;
import 'package:my_dic/features/user/domain/entity/user.dart';

/// Combines the non-editable profile baseline loaded by the auth lifecycle
/// with the editable fields whose source of truth is the local Drift row.
AppUser projectLiveUserProfile({
  required AppUser baseline,
  required db.UserProfile row,
}) {
  final payload = Map<String, Object?>.from(jsonDecode(row.payload) as Map);
  final username = payload['username'];
  return baseline.copyWith(
    username: username is String ? username : baseline.username,
  );
}
