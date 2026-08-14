import 'package:flutter_test/flutter_test.dart';
import 'package:my_dic/features/auth/internal/application/auth_application_service.dart';
import 'package:my_dic/features/auth/port/auth.dart';

import '../../../../../helpers/fake_auth_repository.dart';

void main() {
  group('AuthApplicationService sign-in', () {
    test('validates input before calling its repository port', () async {
      final repository = FakeAuthRepository.success();
      final result = await AuthApplicationService(repository).signIn(
        const SignInCommand(email: '', password: 'password'),
      );

      expect(result.errorOrNull, isA<ValidationError>());
      expect(repository.signInCallCount, 0);
    });

    test('resolves credential submission through the repository port',
        () async {
      final repository = FakeAuthRepository.success();
      final result = await AuthApplicationService(repository).signIn(
        const SignInCommand(
          email: '  user@example.com ',
          password: 'password',
        ),
      );

      expect(result.isSuccess, isTrue);
      expect(repository.lastSignInEmail, 'user@example.com');
    });
  });
}
