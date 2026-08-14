import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:my_dic/features/auth/port/presentation_entry.dart';
import 'package:my_dic/integration/session_lifecycle_workflow/auth_lifecycle_controller.dart';
import 'package:my_dic/integration/session_lifecycle_workflow/auth_lifecycle_provider.dart';

AuthPresentationState _authLifecyclePresentationState(WidgetRef ref) {
  final state = ref.watch(authLifecycleProvider);
  return AuthPresentationState(
    phase: AuthPresentationPhase.values[state.phase.index],
    auth: state.auth,
    error: state.error,
    notice: state.notice,
  );
}

AuthPresentationActions _authLifecyclePresentationActions(WidgetRef ref) =>
    _AuthLifecyclePresentationActions(ref.read(authLifecycleProvider.notifier));

/// App-owned adapter from lifecycle state to Auth's controlled Flutter entry.
class AuthLifecyclePresentationPage extends ConsumerWidget {
  const AuthLifecyclePresentationPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) => AuthPresentationPage(
        state: _authLifecyclePresentationState(ref),
        actions: _authLifecyclePresentationActions(ref),
      );
}

final class _AuthLifecyclePresentationActions
    implements AuthPresentationActions {
  const _AuthLifecyclePresentationActions(this._controller);

  final AuthLifecycleController _controller;

  @override
  Future<void> checkEmailVerification() => _controller.checkEmailVerification();
  @override
  Future<void> resendVerificationEmail() =>
      _controller.resendVerificationEmail();
  @override
  Future<void> retryProfileProvisioning() =>
      _controller.retryProfileProvisioning();
  @override
  Future<void> signIn(String email, String password) =>
      _controller.signIn(email, password);
  @override
  Future<void> signOut() => _controller.signOut();
  @override
  Future<void> signUp(String email, String password) =>
      _controller.signUp(email, password);
}
