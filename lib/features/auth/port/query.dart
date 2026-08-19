import 'package:my_dic/core/shared/utils/result.dart';

import 'model/auth_identity.dart';

/// Authが所有する読み取り専用のID機能。
abstract interface class AuthQueryPort {
  Stream<AuthIdentity?> observeAuthState();
  Future<Result<AuthIdentity>> reloadCurrentAuth();
}
