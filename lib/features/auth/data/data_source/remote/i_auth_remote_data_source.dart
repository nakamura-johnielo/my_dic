import 'package:my_dic/core/domain/entity/auth.dart';

abstract class IAuthRemoteDataSource {
  Stream<AppAuth?> observeAuthState();

  Future<AppAuth> createUserWithEmailAndPassword(String email, String password);

  Future<AppAuth> signInWithEmailAndPassword(String email, String password);

  Future<void> signOut();

  Future<void> sendEmailVerification();

  Future<void> sendPasswordResetEmail({required String email});
}
