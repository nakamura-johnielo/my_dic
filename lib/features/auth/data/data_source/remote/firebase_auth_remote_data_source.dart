import 'package:my_dic/core/domain/entity/auth.dart';
import 'package:my_dic/features/auth/data/data_source/remote/firebase_auth_dao.dart';
import 'package:my_dic/features/auth/data/data_source/remote/i_auth_remote_data_source.dart';
import 'package:my_dic/features/auth/data/dto/auth_dto.dart';

class FirebaseAuthRemoteDataSource implements IAuthRemoteDataSource {
  final FirebaseAuthDao _dao;
  FirebaseAuthRemoteDataSource(this._dao);

  @override
  Stream<AppAuth?> observeAuthState() =>
      _dao.authStateChanges().map((dto) => dto == null ? null : _fromDto(dto));

  @override
  Future<AppAuth> createUserWithEmailAndPassword(String email, String password) async {
    final dto = await _dao.createUserWithEmailAndPassword(email, password);
    return _fromDto(dto);
  }

  @override
  Future<AppAuth> signInWithEmailAndPassword(String email, String password) async {
    final dto = await _dao.signInWithEmailAndPassword(email, password);
    return _fromDto(dto);
  }

  @override
  Future<void> signOut() => _dao.signOut();

  @override
  Future<void> sendEmailVerification() => _dao.sendEmailVerification();

  @override
  Future<void> sendPasswordResetEmail({required String email}) =>
      _dao.sendPasswordResetEmail(email: email);

  AppAuth _fromDto(AuthDTO dto) => AppAuth(
        userId: dto.userId,
        email: dto.email,
        isVerified: dto.emailVerified,
        isLogined: false,
      );
}
