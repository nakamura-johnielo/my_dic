import 'package:my_dic/features/auth/domain/entity/app_auth.dart';

abstract class IAuthStore {
  AppAuth? get state;
  void signOut();
  void sendResetEmailPassword();
  void sendVerifyEmail();
  void update(AppAuth appAuth);
  void clear();
}
