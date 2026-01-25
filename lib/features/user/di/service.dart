import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:my_dic/features/user/di/usecase_di.dart';
import 'package:my_dic/features/user/domain/entity/user.dart';
import 'package:my_dic/features/user/presentation/view_model/app_user_store.dart';




final appUserStoreNotifierProvider =
    StateNotifierProvider<AppUserStoreNotifier, AppUser?>((ref) {
  return AppUserStoreNotifier();
});


