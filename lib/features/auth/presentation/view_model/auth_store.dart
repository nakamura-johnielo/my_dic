import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:my_dic/features/auth/domain/entity/app_auth.dart';
import 'package:my_dic/features/auth/presentation/view_model/i_auth_store.dart';

class AuthStoreNotifier extends StateNotifier<AppAuth?> implements IAuthStore {
  AuthStoreNotifier() : super(null);

  @override
  AppAuth? get state=>state;

  @override
  void signOut() async {
    clear();
  }

  @override
  void update(AppAuth appAuth) {
    state = appAuth;
  }

  @override
  void sendVerifyEmail() async {}

  @override
  void sendResetEmailPassword() {}

  @override
  void clear() {
    state = null;
  }
}
