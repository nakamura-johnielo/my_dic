import 'package:my_dic/_Business_Rule/_Domain/Entities/user/app_auth.dart';
import 'package:my_dic/_Framework_Driver/remote/firebase/Entity/authEntity.dart';

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
