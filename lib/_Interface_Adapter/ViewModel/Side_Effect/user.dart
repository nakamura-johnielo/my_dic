import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:my_dic/_Business_Rule/_Domain/Entities/user/app_auth.dart';
import 'package:my_dic/_Interface_Adapter/ViewModel/user/profile.dart';

final authEffectProvider = Provider<void>((ref) {
  ref.listen<AsyncValue<AppAuth?>>(
    authStreamProvider,
    (previous, next) async {
      print("~~~~~~~~~~");
      print(" suth effect");
      if (next.value != null) {
        print("user valid");
        final appAuth = next.value!;
        // ログイン後、ユーザー情報リロード
        await ref.read(userViewModelProvider.notifier).getUser(appAuth.userId);
        ref.read(userViewModelProvider.notifier).setAuthInfo(appAuth);
      } else {
        // ログアウト時の処理
        final input = AppAuth(userId: 'logout');
        ref.read(userViewModelProvider.notifier).setAuthInfo(input);
        // ref.read(userViewModelProvider.notifier).clear();
      }
    },
  );
});
