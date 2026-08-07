import 'package:flutter_test/flutter_test.dart';
import 'package:my_dic/core/shared/errors/domain_errors.dart';
import 'package:my_dic/features/auth/application/usecase/signin.dart';

import '../../../../../helpers/fake_auth_repository.dart';

void main() {
  group('SignInInteractor', () {
    test('validates input before calling its repository port', () async {
      final repository = FakeAuthRepository.success();
      final result = await SignInInteractor(repository).execute('', 'password');

      expect(result.errorOrNull, isA<ValidationError>());
      expect(repository.signInCallCount, 0);
    });

    test('resolves credential submission through the repository port',
        () async {
      final repository = FakeAuthRepository.success();
      final result = await SignInInteractor(repository)
          .execute('  user@example.com ', 'password');

      expect(result.isSuccess, isTrue);
      expect(repository.lastSignInEmail, 'user@example.com');
    });
  });
}
