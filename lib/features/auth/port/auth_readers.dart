import 'package:my_dic/core/shared/utils/result.dart';

import 'app_auth.dart';

/// Public readers for observing or refreshing the current Auth identity.
abstract interface class ObserveAuthStatePort {
  Stream<AppAuth?> observeAuthState();
}

abstract interface class ReloadCurrentAuthPort {
  Future<Result<AppAuth>> reloadCurrentAuth();
}
