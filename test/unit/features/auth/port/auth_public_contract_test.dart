import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:my_dic/features/auth/port/auth.dart';

void main() {
  test('facade exposes typed identity, commands, ports, result, and errors', () {
    final identity = AuthIdentity(
      accountId: 'account-1',
      email: 'person@example.com',
      provider: AuthProvider.email,
      emailVerified: true,
    );
    const signIn = SignInCommand(
      email: ' person@example.com ',
      password: ' password ',
    );

    expect(identity.emailVerified, isTrue);
    expect(signIn.email, ' person@example.com ');
    expect(signIn.password, ' password ');
    expect(Result<AuthIdentity>.success(identity).dataOrNull, same(identity));
    expect(ValidationError(message: 'invalid'), isA<AppError>());
  });

  test('business facade remains free of Flutter, Riverpod, and Firebase', () {
    final facade = File('lib/features/auth/port/auth.dart').readAsStringSync();
    expect(facade, isNot(contains('flutter')));
    expect(facade, isNot(contains('riverpod')));
    expect(facade, isNot(contains('firebase')));
    expect(facade, isNot(contains('/internal/')));
  });
}
