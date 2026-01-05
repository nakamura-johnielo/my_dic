import 'package:my_dic/features/auth/domain/entity/app_auth.dart';
import 'package:my_dic/core/shared/utils/result.dart';

abstract interface class IAuthRepository {
  Stream<AppAuth?> observeAuthState();
  Future<Result<void>> signOut();
  Future<Result<AppAuth>> signInWithEmailAndPassword(
      {required String email, required String password});
  Future<Result<AppAuth>> createUserWithEmailAndPassword(
      {required String email, required String password});
  Future<Result<void>> sendEmailVerification();
  Future<Result<void>> sendPasswordResetEmail({required String email});
}
