import 'package:my_dic/features/auth/data/data_source/remote/firebase_auth_dao.dart';
import 'package:my_dic/features/auth/data/data_source/remote/i_auth_remote_data_source.dart';
import 'package:my_dic/features/auth/data/dto/auth_dto.dart';

class FirebaseAuthRemoteDataSource implements IAuthRemoteDataSource {
  final FirebaseAuthDao _dao;
  FirebaseAuthRemoteDataSource(this._dao);

  @override
  Stream<AuthDTO?> observeAuthState() => _dao.authStateChanges();

  @override
  Future<AuthDTO?> createUserWithEmailAndPassword(String email, String password) async {
    return await _dao.createUserWithEmailAndPassword(email, password);
  }

  @override
  Future<AuthDTO?> signInWithEmailAndPassword(String email, String password) async {
    return await _dao.signInWithEmailAndPassword(email, password);
  }

  @override
  Future<void> signOut() => _dao.signOut();

  @override
  Future<void> sendEmailVerification() => _dao.sendEmailVerification();

  @override
  Future<void> sendPasswordResetEmail({required String email}) =>
      _dao.sendPasswordResetEmail(email: email);
}
