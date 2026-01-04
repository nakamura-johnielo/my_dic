import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:my_dic/features/user/di/usecase_di.dart';
import 'package:my_dic/features/user/domain/entity/user.dart';
import 'package:my_dic/features/user/presentation/view_model/app_user_store.dart';


// final userServiceProvider = Provider<UserService>((ref) {
//   final getUserInteractor = ref.watch(getUserInteractorProvider);
//   final createUserUsecase = ref.watch(createNewUserInteractorProvider);
//   final updateUserInteractor = ref.watch(updateUserInteractorProvider);
//   final ensureUserExistsInteractor =
//       ref.watch(ensureUserExistsInteractorProvider);
//   final appUserStore = ref.watch(appUserStoreProvider);
//   return UserService(getUserInteractor, updateUserInteractor,
//       ensureUserExistsInteractor, createUserUsecase, appUserStore);
// });

// interface実装済みnotifier
//これを使う
// final appUserStoreProvider = 
//     Provider<IAppUserStore>((ref) {
//   return ref.read(_appUserStoreNotifierProvider.notifier);
// });

// statenotifier これは使わない
//

final appUserStoreNotifierProvider =
    StateNotifierProvider<AppUserStoreNotifier, AppUser?>((ref) {
  return AppUserStoreNotifier();
});


