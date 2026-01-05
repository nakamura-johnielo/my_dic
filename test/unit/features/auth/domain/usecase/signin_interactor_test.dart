/// Test for SignInInteractor UseCase
/// Priority: ★★★★★ (Critical business logic)
/// 
/// Tests demonstrate:
/// - Clean Architecture UseCase testing pattern
/// - Fake repository usage (no mockito/mocktail)
/// - Input validation logic
/// - Result type handling
/// - Error scenario coverage

import 'package:flutter_test/flutter_test.dart';
import 'package:my_dic/core/shared/errors/domain_errors.dart';
import 'package:my_dic/core/shared/errors/infrastructure_errors.dart';
import 'package:my_dic/features/auth/domain/usecase/signin.dart';

import '../../../../../helpers/fake_auth_repository.dart';
import '../../../../../helpers/test_helpers.dart';


void main() {
  group('SignInInteractor', () {
    group('Input Validation', () {
      test('execute_returnsValidationError_whenEmailIsEmpty', () async {
        // Arrange
        final repository = FakeAuthRepository.success();
        final useCase = SignInInteractor(repository);

        // Act
        final result = await useCase.execute('', 'password123');

        // Assert
        expect(result.isFailure, true);
        expect(result.errorOrNull, isA<ValidationError>());
        
        final error = result.errorOrNull as ValidationError;
        expect(error.fieldErrors, isNotNull);
        expect(error.fieldErrors!['email'], isNotNull);
        expect(
          error.fieldErrors!['email']!.first,
          'メールアドレスを入力してください',
        );
        
        // Verify repository was not called
        expect(repository.signInCallCount, 0);
      });

      test('execute_returnsValidationError_whenEmailIsWhitespace', () async {
        // Arrange
        final repository = FakeAuthRepository.success();
        final useCase = SignInInteractor(repository);

        // Act
        final result = await useCase.execute('   ', 'password123');

        // Assert
        expect(result.isFailure, true);
        expect(result.errorOrNull, isA<ValidationError>());
        
        final error = result.errorOrNull as ValidationError;
        expect(error.fieldErrors!['email'], isNotNull);
      });

      test('execute_returnsValidationError_whenPasswordIsEmpty', () async {
        // Arrange
        final repository = FakeAuthRepository.success();
        final useCase = SignInInteractor(repository);

        // Act
        final result = await useCase.execute('test@example.com', '');

        // Assert
        expect(result.isFailure, true);
        expect(result.errorOrNull, isA<ValidationError>());
        
        final error = result.errorOrNull as ValidationError;
        expect(error.fieldErrors, isNotNull);
        expect(error.fieldErrors!['password'], isNotNull);
        expect(
          error.fieldErrors!['password']!.first,
          'パスワードを入力してください',
        );
      });

      test('execute_returnsValidationError_whenBothEmailAndPasswordEmpty', () async {
        // Arrange
        final repository = FakeAuthRepository.success();
        final useCase = SignInInteractor(repository);

        // Act
        final result = await useCase.execute('', '');

        // Assert
        expect(result.isFailure, true);
        expect(result.errorOrNull, isA<ValidationError>());
        
        final error = result.errorOrNull as ValidationError;
        expect(error.fieldErrors, isNotNull);
        expect(error.fieldErrors!['email'], isNotNull);
        expect(error.fieldErrors!['password'], isNotNull);
      });
    });

    group('Success Scenario', () {
      test('execute_returnsSuccess_whenCredentialsAreValid', () async {
        // Arrange
        final testAuth = createTestAuth(
          userId: 'user-123',
          email: 'test@example.com',
          isLogined: true,
        );
        final repository = FakeAuthRepository.success(auth: testAuth);
        final useCase = SignInInteractor(repository);

        // Act
        final result = await useCase.execute('test@example.com', 'password123');

        // Assert
        expect(result.isSuccess, true);
        expect(result.dataOrNull, isNotNull);
        expect(result.dataOrNull?.userId, 'user-123');
        expect(result.dataOrNull?.email, 'test@example.com');
        expect(result.dataOrNull?.isLogined, true);
        
        // Verify repository was called with trimmed email
        expect(repository.signInCallCount, 1);
        expect(repository.lastSignInEmail, 'test@example.com');
        expect(repository.lastSignInPassword, 'password123');
      });

      test('execute_trimsEmail_beforeCallingRepository', () async {
        // Arrange
        final repository = FakeAuthRepository.success();
        final useCase = SignInInteractor(repository);

        // Act
        await useCase.execute('  test@example.com  ', 'password123');

        // Assert
        expect(repository.lastSignInEmail, 'test@example.com');
      });
    });

    group('Failure Scenarios', () {
      test('execute_returnsUnauthorizedError_whenCredentialsAreInvalid', () async {
        // Arrange
        final repository = FakeAuthRepository.invalidCredentials();
        final useCase = SignInInteractor(repository);

        // Act
        final result = await useCase.execute('test@example.com', 'wrongpassword');

        // Assert
        expect(result.isFailure, true);
        expect(result.errorOrNull, isA<UnauthorizedError>());
        expect(
          result.errorOrNull?.message,
          'メールアドレスまたはパスワードが正しくありません',
        );
      });

      test('execute_returnsNotFoundError_whenUserDoesNotExist', () async {
        // Arrange
        final repository = FakeAuthRepository.userNotFound();
        final useCase = SignInInteractor(repository);

        // Act
        final result = await useCase.execute('unknown@example.com', 'password123');

        // Assert
        expect(result.isFailure, true);
        expect(result.errorOrNull, isA<NotFoundError>());
        expect(result.errorOrNull?.message, 'ユーザーが見つかりません');
      });

      test('execute_returnsNetworkError_whenNetworkFails', () async {
        // Arrange
        final repository = FakeAuthRepository.networkError();
        final useCase = SignInInteractor(repository);

        // Act
        final result = await useCase.execute('test@example.com', 'password123');

        // Assert
        expect(result.isFailure, true);
        expect(result.errorOrNull, isA<NetworkError>());
        expect(
          result.errorOrNull?.message,
          'ネットワークエラーが発生しました',
        );
      });
    });
  });
}
