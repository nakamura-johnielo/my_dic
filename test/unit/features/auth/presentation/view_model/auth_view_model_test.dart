/// Test for AuthViewModel
/// Priority: ★★★★☆ (Critical state management demonstration)
/// 
/// Tests demonstrate:
/// - ProviderContainer usage for Riverpod testing
/// - Provider overriding with Fake UseCases
/// - State transition verification
/// - Error message handling
/// - Complex business logic (email verification flow)
/// 
/// This is the MOST IMPORTANT test for technical recruiters
/// showing proper Riverpod testing patterns

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:my_dic/core/shared/enums/subscription_status.dart';
import 'package:my_dic/core/shared/errors/domain_errors.dart';
import 'package:my_dic/core/shared/utils/result.dart';
import 'package:my_dic/features/auth/di/usecase_di.dart';
import 'package:my_dic/features/auth/di/view_model_di.dart';
import 'package:my_dic/features/auth/di/data_di.dart';
import 'package:my_dic/features/user/presentation/model/user_profile_ui_model.dart';

import '../../../../../helpers/fake_auth_usecases.dart';
import '../../../../../helpers/test_helpers.dart';


void main() {
  group('AuthViewModel', () {
    late ProviderContainer container;

    tearDown(() {
      container.dispose();
    });

    group('SignIn - Success with Verified User', () {
      test('signIn_updatesState_whenUserIsVerified', () async {
        // Arrange
        final fakeSignIn = FakeSignInInteractor(
          executeResult: Result.success(
            createTestAuth(
              userId: 'user-123',
              email: 'test@example.com',
              isVerified: true,
            ),
          ),
        );
        final fakeVerifyEmail = FakeVerifyEmailInteractor();
        final fakeSignUp = FakeSignUpInteractor();
        final fakeSignOut = FakeSignOutInteractor();

        container = ProviderContainer(
          overrides: [
            signInInteractorProvider.overrideWithValue(fakeSignIn),
            verificateInteractorProvider.overrideWithValue(fakeVerifyEmail),
            signUpInteractorProvider.overrideWithValue(fakeSignUp),
            signOutInteractorProvider.overrideWithValue(fakeSignOut),
          ],
        );

        // Set initial state
        final viewModel = container.read(authViewModelProvider.notifier);
        viewModel.state = UserState(
          id: '',
          email: '',
          username: '',
          subscriptionStatus: SubscriptionStatus.free,
        );

        // Act
        final message = await viewModel.signIn('test@example.com', 'password123');

        // Assert
        expect(message, 'ログインに成功しました');

        final state = container.read(authViewModelProvider);
        expect(state, isNotNull);
        expect(state!.id, 'user-123');
        expect(state.email, 'test@example.com');
        expect(state.isAuthorized, true);

        // Verify UseCase was called
        expect(fakeSignIn.callCount, 1);
        expect(fakeSignIn.lastEmail, 'test@example.com');
        expect(fakeSignIn.lastPassword, 'password123');

        // Verify email verification was NOT called (user already verified)
        expect(fakeVerifyEmail.callCount, 0);
      });
    });

    group('SignIn - Unverified User Flow', () {
      test('signIn_sendsVerificationEmail_whenUserIsNotVerified', () async {
        // Arrange
        final fakeSignIn = FakeSignInInteractor(
          executeResult: Result.success(
            createTestAuth(
              isVerified: false, // Unverified user
            ),
          ),
        );
        final fakeVerifyEmail = FakeVerifyEmailInteractor(
          executeResult: const Result.success(null),
        );
        final fakeSignUp = FakeSignUpInteractor();
        final fakeSignOut = FakeSignOutInteractor();

        container = ProviderContainer(
          overrides: [
            signInInteractorProvider.overrideWithValue(fakeSignIn),
            verificateInteractorProvider.overrideWithValue(fakeVerifyEmail),
            signUpInteractorProvider.overrideWithValue(fakeSignUp),
            signOutInteractorProvider.overrideWithValue(fakeSignOut),
          ],
        );

        final viewModel = container.read(authViewModelProvider.notifier);

        // Act
        final message = await viewModel.signIn('test@example.com', 'password123');

        // Assert
        expect(message, '確認メールを送信しました');

        // Verify email verification WAS called
        expect(fakeVerifyEmail.callCount, 1);

        // State should NOT be updated (user not verified)
        final state = container.read(authViewModelProvider);
        expect(state, isNull);
      });

      test('signIn_returnsErrorMessage_whenVerificationEmailFails', () async {
        // Arrange
        final fakeSignIn = FakeSignInInteractor(
          executeResult: Result.success(
            createTestAuth(isVerified: false),
          ),
        );
        final fakeVerifyEmail = FakeVerifyEmailInteractor(
          executeResult: Result.failure(
            BusinessRuleError(message: 'メール送信に失敗'),
          ),
        );
        final fakeSignUp = FakeSignUpInteractor();
        final fakeSignOut = FakeSignOutInteractor();

        container = ProviderContainer(
          overrides: [
            signInInteractorProvider.overrideWithValue(fakeSignIn),
            verificateInteractorProvider.overrideWithValue(fakeVerifyEmail),
            signUpInteractorProvider.overrideWithValue(fakeSignUp),
            signOutInteractorProvider.overrideWithValue(fakeSignOut),
          ],
        );

        final viewModel = container.read(authViewModelProvider.notifier);

        // Act
        final message = await viewModel.signIn('test@example.com', 'password123');

        // Assert
        expect(message, 'ログイン成功しましたが、確認メールの送信に失敗しました');
      });
    });

    group('SignIn - Failure Scenarios', () {
      test('signIn_returnsErrorMessage_whenCredentialsAreInvalid', () async {
        // Arrange
        final fakeSignIn = FakeSignInInteractor(
          executeResult: Result.failure(
            UnauthorizedError(
              message: 'メールアドレスまたはパスワードが正しくありません',
            ),
          ),
        );
        final fakeVerifyEmail = FakeVerifyEmailInteractor();
        final fakeSignUp = FakeSignUpInteractor();
        final fakeSignOut = FakeSignOutInteractor();

        container = ProviderContainer(
          overrides: [
            signInInteractorProvider.overrideWithValue(fakeSignIn),
            verificateInteractorProvider.overrideWithValue(fakeVerifyEmail),
            signUpInteractorProvider.overrideWithValue(fakeSignUp),
            signOutInteractorProvider.overrideWithValue(fakeSignOut),
          ],
        );

        final viewModel = container.read(authViewModelProvider.notifier);

        // Act
        final message = await viewModel.signIn('wrong@example.com', 'wrongpass');

        // Assert
        expect(message, 'メールアドレスまたはパスワードが正しくありません');

        // State should not be updated
        final state = container.read(authViewModelProvider);
        expect(state, isNull);
      });
    });

    group('SignUp', () {
      test('signUp_sendsVerificationEmail_whenUserIsNotVerified', () async {
        // Arrange
        final fakeSignIn = FakeSignInInteractor();
        final fakeSignUp = FakeSignUpInteractor(
          executeResult: Result.success(
            createTestAuth(isVerified: false),
          ),
        );
        final fakeVerifyEmail = FakeVerifyEmailInteractor();
        final fakeSignOut = FakeSignOutInteractor();

        container = ProviderContainer(
          overrides: [
            signInInteractorProvider.overrideWithValue(fakeSignIn),
            signUpInteractorProvider.overrideWithValue(fakeSignUp),
            verificateInteractorProvider.overrideWithValue(fakeVerifyEmail),
            signOutInteractorProvider.overrideWithValue(fakeSignOut),
          ],
        );

        final viewModel = container.read(authViewModelProvider.notifier);

        // Act
        final message = await viewModel.signUp('new@example.com', 'password123');

        // Assert
        expect(message, '確認メールを送信しました');
        expect(fakeSignUp.callCount, 1);
        expect(fakeVerifyEmail.callCount, 1);
      });
    });

    group('SignOut', () {
      test('signOut_returnsSuccessMessage_whenSignOutSucceeds', () async {
        // Arrange
        final fakeSignIn = FakeSignInInteractor();
        final fakeSignUp = FakeSignUpInteractor();
        final fakeVerifyEmail = FakeVerifyEmailInteractor();
        final fakeSignOut = FakeSignOutInteractor();

        container = ProviderContainer(
          overrides: [
            signInInteractorProvider.overrideWithValue(fakeSignIn),
            signUpInteractorProvider.overrideWithValue(fakeSignUp),
            verificateInteractorProvider.overrideWithValue(fakeVerifyEmail),
            signOutInteractorProvider.overrideWithValue(fakeSignOut),
          ],
        );

        final viewModel = container.read(authViewModelProvider.notifier);

        // Act
        final message = await viewModel.signOut();

        // Assert
        expect(message, 'ログアウトしました');
        expect(fakeSignOut.callCount, 1);
      });

      test('signOut_returnsErrorMessage_whenSignOutFails', () async {
        // Arrange
        final fakeSignIn = FakeSignInInteractor();
        final fakeSignUp = FakeSignUpInteractor();
        final fakeVerifyEmail = FakeVerifyEmailInteractor();
        final fakeSignOut = FakeSignOutInteractor(
          executeResult: Result.failure(
            BusinessRuleError(message: 'ログアウトエラー'),
          ),
        );

        container = ProviderContainer(
          overrides: [
            signInInteractorProvider.overrideWithValue(fakeSignIn),
            signUpInteractorProvider.overrideWithValue(fakeSignUp),
            verificateInteractorProvider.overrideWithValue(fakeVerifyEmail),
            signOutInteractorProvider.overrideWithValue(fakeSignOut),
          ],
        );

        final viewModel = container.read(authViewModelProvider.notifier);

        // Act
        final message = await viewModel.signOut();

        // Assert
        expect(message, contains('ログアウトに失敗しました'));
      });
    });

    group('VerifyEmail', () {
      test('verifyEmail_returnsSuccessMessage_whenEmailSent', () async {
        // Arrange
        final fakeSignIn = FakeSignInInteractor();
        final fakeSignUp = FakeSignUpInteractor();
        final fakeVerifyEmail = FakeVerifyEmailInteractor();
        final fakeSignOut = FakeSignOutInteractor();

        container = ProviderContainer(
          overrides: [
            signInInteractorProvider.overrideWithValue(fakeSignIn),
            signUpInteractorProvider.overrideWithValue(fakeSignUp),
            verificateInteractorProvider.overrideWithValue(fakeVerifyEmail),
            signOutInteractorProvider.overrideWithValue(fakeSignOut),
          ],
        );

        final viewModel = container.read(authViewModelProvider.notifier);

        // Act
        final message = await viewModel.verifyEmail();

        // Assert
        expect(message, '確認メールを送信しました');
        expect(fakeVerifyEmail.callCount, 1);
      });
    });
  });
}
