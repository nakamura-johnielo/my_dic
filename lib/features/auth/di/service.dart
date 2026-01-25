import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:my_dic/features/auth/domain/entity/app_auth.dart';
import 'package:my_dic/features/auth/presentation/view_model/auth_store.dart';






// statenotifier これは使わない
final authStoreNotifierProvider =
    StateNotifierProvider<AuthStoreNotifier, AppAuth?>((ref) {
  return AuthStoreNotifier();
});
