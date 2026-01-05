/// Widget Test for Auth State Display
/// Priority: ★★☆☆☆ (Minimal - only state-based display testing)
/// 
/// Tests demonstrate:
/// - State-based UI rendering (loading, success, error)
/// - Minimal widget testing approach per test_query.md
/// - NO layout/style/color testing
/// - Focus on conditional display logic only

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:my_dic/core/domain/entity/auth.dart';
import 'package:my_dic/core/shared/enums/subscription_status.dart';
import 'package:my_dic/core/shared/errors/domain_errors.dart';
import 'package:my_dic/core/shared/utils/result.dart';
import 'package:my_dic/features/auth/di/view_model_di.dart';
import 'package:my_dic/features/auth/domain/I_repository/i_auth_repository.dart';
import 'package:my_dic/features/auth/domain/usecase/signin.dart';
import 'package:my_dic/features/auth/domain/usecase/signout.dart';
import 'package:my_dic/features/auth/domain/usecase/signup.dart';
import 'package:my_dic/features/auth/domain/usecase/verify_email.dart';
import 'package:my_dic/features/auth/presentation/view_model/auth_view_model.dart';
import 'package:my_dic/features/user/presentation/model/user_profile_ui_model.dart';

void main() {
  group('Auth State Display Widget Test', () {
    testWidgets('displays_noUserInfo_whenStateIsNull', (tester) async {
      // Arrange
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            // Override with null state directly
            authViewModelProvider.overrideWith(
              (ref) => _TestAuthViewModel(null),
            ),
          ],
          child: MaterialApp(
            home: Scaffold(
              body: Consumer(
                builder: (context, ref, child) {
                  final state = ref.watch(authViewModelProvider);

                  if (state == null) {
                    return const Text('ログインしてください');
                  }

                  if (!state.isAuthorized) {
                    return const Text('メールを確認してください');
                  }

                  return Text('ようこそ ${state.email}');
                },
              ),
            ),
          ),
        ),
      );

      // Act
      await tester.pump();

      // Assert
      expect(find.text('ログインしてください'), findsOneWidget);
      expect(find.textContaining('ようこそ'), findsNothing);
    });

    testWidgets('displays_verificationMessage_whenUserIsNotAuthorized',
        (tester) async {
      // Arrange
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            authViewModelProvider.overrideWith(
              (ref) => _TestAuthViewModel(
                UserState(
                  id: 'test-123',
                  email: 'test@example.com',
                  username: 'Test User',
                  subscriptionStatus: SubscriptionStatus.free,
                  isLoggedIn: true,
                  isAuthorized: false, // Not verified
                ),
              ),
            ),
          ],
          child: MaterialApp(
            home: Scaffold(
              body: Consumer(
                builder: (context, ref, child) {
                  final state = ref.watch(authViewModelProvider);

                  if (state == null) {
                    return const Text('ログインしてください');
                  }

                  if (!state.isAuthorized) {
                    return const Text('メールを確認してください');
                  }

                  return Text('ようこそ ${state.email}');
                },
              ),
            ),
          ),
        ),
      );

      // Act
      await tester.pump();

      // Assert
      expect(find.text('メールを確認してください'), findsOneWidget);
      expect(find.text('ログインしてください'), findsNothing);
      expect(find.textContaining('ようこそ'), findsNothing);
    });

    testWidgets('displays_welcomeMessage_whenUserIsAuthorized', (tester) async {
      // Arrange
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            authViewModelProvider.overrideWith(
              (ref) => _TestAuthViewModel(
                UserState(
                  id: 'test-123',
                  email: 'verified@example.com',
                  username: 'Verified User',
                  subscriptionStatus: SubscriptionStatus.free,
                  isLoggedIn: true,
                  isAuthorized: true, // Verified!
                ),
              ),
            ),
          ],
          child: MaterialApp(
            home: Scaffold(
              body: Consumer(
                builder: (context, ref, child) {
                  final state = ref.watch(authViewModelProvider);

                  if (state == null) {
                    return const Text('ログインしてください');
                  }

                  if (!state.isAuthorized) {
                    return const Text('メールを確認してください');
                  }

                  return Text('ようこそ ${state.email}');
                },
              ),
            ),
          ),
        ),
      );

      // Act
      await tester.pump();

      // Assert
      expect(find.text('ようこそ verified@example.com'), findsOneWidget);
      expect(find.text('ログインしてください'), findsNothing);
      expect(find.text('メールを確認してください'), findsNothing);
    });
  });
}

/// Test-only AuthViewModel for widget testing
/// This allows us to control state without calling actual UseCases
/// Extends AuthViewModel to ensure type compatibility
class _TestAuthViewModel extends AuthViewModel {
  _TestAuthViewModel(UserState? initialState)
      : super(
          _FakeSignInInteractor(),
          _FakeSignUpInteractor(),
          _FakeVerifyEmailInteractor(),
          _FakeSignOutInteractor(),
        ) {
    state = initialState;
  }
}

// Minimal fake implementations for dependencies
class _FakeSignInInteractor extends SignInInteractor {
  _FakeSignInInteractor() : super(_FakeAuthRepository());
}

class _FakeSignUpInteractor extends SignUpInteractor {
  _FakeSignUpInteractor() : super(_FakeAuthRepository());
}

class _FakeVerifyEmailInteractor extends VerifyEmailInteractor {
  _FakeVerifyEmailInteractor() : super(_FakeAuthRepository());
}

class _FakeSignOutInteractor extends SignOutInteractor {
  _FakeSignOutInteractor() : super(_FakeAuthRepository());
}

class _FakeAuthRepository implements IAuthRepository {
  @override
  Future<Result<AppAuth>> signInWithEmailAndPassword({
    required String email,
    required String password,
  }) async =>
      Result.failure(UnauthorizedError(message: 'Not implemented'));

  @override
  Future<Result<AppAuth>> createUserWithEmailAndPassword({
    required String email,
    required String password,
  }) async =>
      Result.failure(UnauthorizedError(message: 'Not implemented'));

  @override
  Future<Result<void>> signOut() async => const Result.success(null);

  @override
  Future<Result<void>> sendEmailVerification() async =>
      const Result.success(null);

  @override
  Future<Result<void>> sendPasswordResetEmail({required String email}) async =>
      const Result.success(null);

  @override
  Stream<AppAuth?> observeAuthState() => Stream.value(null);
}
