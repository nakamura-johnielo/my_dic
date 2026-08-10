import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:my_dic/features/auth/port/presentation_entry.dart';
import 'auth_lifecycle_controller.dart';
import 'auth_lifecycle_provider.dart';

AuthPresentationState authLifecyclePresentationState(Ref ref) {
  final state = ref.watch(authLifecycleProvider);
  return AuthPresentationState(
    phase: AuthPresentationPhase.values[state.phase.index],
    auth: state.auth,
    error: state.error,
    notice: state.notice,
  );
}

AuthPresentationActions authLifecyclePresentationActions(Ref ref) =>
    _AuthLifecyclePresentationActions(ref.read(authLifecycleProvider.notifier));

final class _AuthLifecyclePresentationActions implements AuthPresentationActions {
  const _AuthLifecyclePresentationActions(this._controller);
  final AuthLifecycleController _controller;

  @override
  Future<void> checkEmailVerification() => _controller.checkEmailVerification();
  @override
  Future<void> resendVerificationEmail() => _controller.resendVerificationEmail();
  @override
  Future<void> retryProfileProvisioning() => _controller.retryProfileProvisioning();
  @override
  Future<void> signIn(String email, String password) => _controller.signIn(email, password);
  @override
  Future<void> signOut() => _controller.signOut();
  @override
  Future<void> signUp(String email, String password) => _controller.signUp(email, password);
}
