import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:my_dic/features/auth/data/data_source/remote/firebase_auth_dao.dart';
import 'package:my_dic/features/auth/data/data_source/remote/firebase_auth_remote_data_source.dart';
import 'package:my_dic/features/auth/data/dto/auth_dto.dart';

class _MockFirebaseAuthDao extends Mock implements FirebaseAuthDao {}

void main() {
  late _MockFirebaseAuthDao dao;
  late FirebaseAuthRemoteDataSource dataSource;

  setUp(() {
    dao = _MockFirebaseAuthDao();
    dataSource = FirebaseAuthRemoteDataSource(dao);
  });

  test('sign in delegates credentials and returns the DAO result unchanged',
      () async {
    final expected = AuthDTO(
      accountId: 'account-1',
      email: 'person@example.com',
      isVerified: true,
    );
    when(
      () => dao.signInWithEmailAndPassword(
        'person@example.com',
        'password-value',
      ),
    ).thenAnswer((_) async => expected);

    final actual = await dataSource.signInWithEmailAndPassword(
      'person@example.com',
      'password-value',
    );

    expect(actual, same(expected));
    verify(
      () => dao.signInWithEmailAndPassword(
        'person@example.com',
        'password-value',
      ),
    ).called(1);
  });

  test('sign out delegates to the DAO exactly once', () async {
    when(() => dao.signOut()).thenAnswer((_) async {});

    await dataSource.signOut();

    verify(() => dao.signOut()).called(1);
  });

  test('reload delegates to the DAO and returns the refreshed identity',
      () async {
    final expected = AuthDTO(
      accountId: 'account-1',
      email: 'person@example.com',
      isVerified: true,
    );
    when(() => dao.reloadCurrentAuth()).thenAnswer((_) async => expected);

    final actual = await dataSource.reloadCurrentAuth();

    expect(actual, same(expected));
    verify(() => dao.reloadCurrentAuth()).called(1);
  });
}
