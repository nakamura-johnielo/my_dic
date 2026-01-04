import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:my_dic/core/shared/enums/auth/provider_type.dart';
import 'package:my_dic/features/auth/domain/entity/app_auth.dart';

class AuthStoreNotifier extends StateNotifier<AppAuth?>  {
  AuthStoreNotifier() : super(null);


  void signOut() async {
    clear();
  }

  void setAuth(AppAuth appAuth) {
    state = appAuth;
  }

  void update({
    String? id,
    bool? isLogined,
    bool? isAuthenticated,
    ProviderType? provider,
  }){
    state = state?.copyWith(
        id: id,
        isLogined: isLogined,
        isAuthenticated: isAuthenticated,
        provider: provider);
  }

  void clear() {
    state = null;
  }
}
