import 'package:my_dic/features/auth/port/auth.dart';

abstract interface class IAuthRepository {
  Stream<AuthIdentity?> observeAuthState();
  Future<Result<void>> signOut();
  Future<Result<AuthIdentity>> signInWithEmailAndPassword(
      {required String email, required String password});
  Future<Result<AuthIdentity>> createUserWithEmailAndPassword(
      {required String email, required String password});
  Future<Result<void>> sendEmailVerification();
  Future<Result<void>> sendPasswordResetEmail({required String email});
  Future<Result<AuthIdentity>> getCurrentAuth();
  Future<Result<AuthIdentity>> reloadCurrentAuth();
}
