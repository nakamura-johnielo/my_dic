import 'package:my_dic/core/domain/entity/auth.dart';
import 'package:my_dic/features/auth/data/dto/auth_dto.dart';

abstract interface class IAuthRepository {
  Stream<AppAuth?> observeAuthState();
  Future<void> signOut();
  Future<AppAuth> signInWithEmailAndPassword(
      {required String email, required String password});
  Future<AppAuth> createUserWithEmailAndPassword(
      {required String email, required String password});
  Future<void> sendEmailVerification();
  Future<void> sendPasswordResetEmail({required String email});
}
