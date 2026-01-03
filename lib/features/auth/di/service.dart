import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:my_dic/features/auth/auth_service.dart';
import 'package:my_dic/features/auth/di/usecase_di.dart';
import 'package:my_dic/features/auth/domain/entity/app_auth.dart';
import 'package:my_dic/features/auth/presentation/view_model/auth_store.dart';
import 'package:my_dic/features/auth/presentation/view_model/i_auth_store.dart';


// interface実装済みnotifier
//これを使う
final authStoreProvider =
    Provider<IAuthStore>((ref) {
  return ref.read(_authStoreNotifierProvider.notifier);
});


// service
final authServiceProvider = Provider<AuthService>((ref) {
  final authStore = ref.read(authStoreProvider);

  final signInInteractor = ref.watch(signInInteractorProvider);
  final signUpInteractor = ref.watch(signUpInteractorProvider);
  final verficateInteractor = ref.watch(verificateInteractorProvider);
  final signOutInteractor = ref.watch(signOutInteractorProvider);
  final resetEmailPasswordInteractor =
      ref.watch(resetEmailPasswordInteractorProvider);
  final observeAuthStateUseCase = ref.read(observeAuthStateUseCaseProvider);

  return AuthService(
    authStore: authStore,
    observeAuthStateUseCase: observeAuthStateUseCase,
    resetEmailPasswordUseCase: resetEmailPasswordInteractor,
    signInUseCase: signInInteractor,
    signUpUseCase: signUpInteractor,
    signOutUseCase: signOutInteractor,
    verifyEmailUseCase: verficateInteractor,
  );
});




// statenotifier これは使わない
final _authStoreNotifierProvider =
    StateNotifierProvider<AuthStoreNotifier, AppAuth?>((ref) {
  return AuthStoreNotifier();
});
