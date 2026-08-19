import 'dart:convert';

import 'package:my_dic/core/infrastructure/database/drift/database_provider.dart'
    as db;
import 'package:my_dic/features/user_profile/port/user_profile.dart';

/// 認証ライフサイクルで読み込んだ編集不可のプロフィール基準値と、ローカル Drift 行を
/// 信頼できる情報源とする編集可能フィールドを組み合わせます。
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
