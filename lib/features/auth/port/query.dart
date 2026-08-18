import 'package:my_dic/core/shared/utils/result.dart';

import 'model/auth_identity.dart';

/// Auth-owned read-only identity capabilities.
abstract interface class AuthQueryPort {
  Stream<AuthIdentity?> observeAuthState();
  Future<Result<AuthIdentity>> reloadCurrentAuth();
}
