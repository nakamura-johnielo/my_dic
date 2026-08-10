import 'package:my_dic/features/auth/internal/application/auth_dto.dart';

abstract class IAuthRemoteDataSource {
  Stream<AuthDTO?> observeAuthState();

  Future<AuthDTO?> createUserWithEmailAndPassword(
      String email, String password);

  Future<AuthDTO?> signInWithEmailAndPassword(String email, String password);

  Future<void> signOut();

  Future<void> sendEmailVerification();

  Future<void> sendPasswordResetEmail({required String email});

  Future<AuthDTO?> getCurrentAuth();

  Future<AuthDTO?> reloadCurrentAuth();
}
