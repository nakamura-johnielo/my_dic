import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:my_dic/app/bootstrap/firebase_providers.dart';
import 'package:my_dic/features/auth/port/composition.dart';

final class _FirebaseAuth extends Mock implements firebase_auth.FirebaseAuth {}
final class _UserCredential extends Mock
    implements firebase_auth.UserCredential {}
final class _User extends Mock implements firebase_auth.User {}

void main() {
  late _FirebaseAuth auth;
  late FirebaseAuthDataSource gateway;

  setUp(() {
    auth = _FirebaseAuth();
    gateway = FirebaseAuthDataSource(auth);
  });

  test('sign in preserves credential order and maps the returned identity',
      () async {
    final credential = _UserCredential();
    final user = _User();
    when(() => user.uid).thenReturn('account-1');
    when(() => user.email).thenReturn('person@example.com');
    when(() => user.emailVerified).thenReturn(true);
    when(() => credential.user).thenReturn(user);
    when(() => credential.credential).thenReturn(null);
    when(
      () => auth.signInWithEmailAndPassword(
        email: 'person@example.com',
        password: 'password-value',
      ),
    ).thenAnswer((_) async => credential);

    final identity = await gateway.signInWithEmailAndPassword(
      'person@example.com',
      'password-value',
    );

    expect(identity?.accountId, 'account-1');
    expect(identity?.email, 'person@example.com');
    expect(identity?.emailVerified, isTrue);
    verify(
      () => auth.signInWithEmailAndPassword(
        email: 'person@example.com',
        password: 'password-value',
      ),
    ).called(1);
  });

  test('sign out delegates exactly once', () async {
    when(() => auth.signOut()).thenAnswer((_) async {});

    await gateway.signOut();

    verify(() => auth.signOut()).called(1);
  });

  test('Firebase failures cross the boundary as an SDK-free failure', () async {
    final original = firebase_auth.FirebaseAuthException(
      code: 'invalid-credential',
      message: 'credential rejected',
    );
    when(
      () => auth.signInWithEmailAndPassword(
        email: 'person@example.com',
        password: 'password-value',
      ),
    ).thenThrow(original);

    await expectLater(
      gateway.signInWithEmailAndPassword(
        'person@example.com',
        'password-value',
      ),
      throwsA(
        isA<AuthRuntimeFailure>()
            .having((error) => error.code, 'code', 'invalid-credential')
            .having(
              (error) => error.originalError,
              'originalError',
              same(original),
            ),
      ),
    );
  });
}
