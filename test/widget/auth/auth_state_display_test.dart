import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:my_dic/app/workflows/session_lifecycle/auth_lifecycle_controller.dart';
import 'package:my_dic/core/shared/errors/domain_errors.dart';
import 'package:my_dic/core/shared/utils/result.dart';
import 'package:my_dic/features/auth/port/presentation_entry.dart';

import '../../helpers/fake_auth_usecases.dart';
import '../../helpers/fake_user_usecases.dart';
import '../../helpers/test_helpers.dart';

void main() {
  testWidgets('signed-out state displays authentication actions',
      (tester) async {
    final controller = _controller();
    await controller.handleAuthStateChange(null);

    await tester.pumpWidget(_app(controller));

    expect(find.text('Sign Up'), findsOneWidget);
    expect(find.text('Sign In'), findsOneWidget);
    expect(find.text('確認済み'), findsNothing);
  });

  testWidgets('unverified state displays verification and retry actions',
      (tester) async {
    final controller = _controller();
    await controller.handleAuthStateChange(
      createTestAuth(isVerified: false),
    );

    await tester.pumpWidget(_app(controller));

    expect(find.text('確認済み'), findsOneWidget);
    expect(find.text('確認メールを再送'), findsOneWidget);
    expect(find.text('Sign Up'), findsNothing);
  });

  testWidgets('verification delivery failure never displays a sent message',
      (tester) async {
    final controller = _controller(
      verify: FakeVerifyEmailInteractor(
        executeResult: Result.failure(
          BusinessRuleError(message: '送信制限中です'),
        ),
      ),
    );
    await controller.signUp('new@example.com', 'password123');

    await tester.pumpWidget(_app(controller));

    expect(
      find.text('アカウントは作成されましたが、確認メールを送信できませんでした。'),
      findsOneWidget,
    );
    expect(find.textContaining('確認メールを送信しました'), findsNothing);
    expect(find.text('確認メールを再送'), findsOneWidget);
  });
}

Widget _app(AuthLifecycleController controller) {
  return ProviderScope(
    child: MaterialApp(
      home: AuthPresentationPage(
        state: AuthPresentationState(
          phase: AuthPresentationPhase.values[controller.state.phase.index],
          auth: controller.state.auth,
          error: controller.state.error,
          notice: controller.state.notice,
        ),
        actions: _Actions(controller),
      ),
    ),
  );
}

final class _Actions implements AuthPresentationActions {
  const _Actions(this._controller);
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

AuthLifecycleController _controller({FakeVerifyEmailInteractor? verify}) {
  return AuthLifecycleController(
    signIn: FakeSignInInteractor(),
    signUp: FakeSignUpInteractor(),
    signOut: FakeSignOutInteractor(),
    sendVerificationEmail: verify ?? FakeVerifyEmailInteractor(),
    reloadCurrentAuth: FakeReloadCurrentAuthInteractor(),
    ensureUserExists: FakeEnsureUserExistsInteractor(),
  );
}
