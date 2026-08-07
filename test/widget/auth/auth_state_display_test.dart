import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:my_dic/core/application/auth_lifecycle/auth_lifecycle_controller.dart';
import 'package:my_dic/core/application/auth_lifecycle/auth_lifecycle_provider.dart';
import 'package:my_dic/core/shared/errors/domain_errors.dart';
import 'package:my_dic/core/shared/utils/result.dart';
import 'package:my_dic/features/auth/presentation/view/sign_up.dart';

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
    overrides: [
      authLifecycleProvider.overrideWith((ref) => controller),
    ],
    child: const MaterialApp(home: EmailPasswordPage()),
  );
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
