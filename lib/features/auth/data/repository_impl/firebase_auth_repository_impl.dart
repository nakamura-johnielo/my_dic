import 'package:my_dic/core/domain/entity/auth.dart';
import 'package:my_dic/features/auth/domain/I_repository/i_auth_repository.dart';
import 'package:my_dic/features/auth/data/data_source/remote/firebase_auth_dao.dart';
import 'package:my_dic/features/auth/data/dto/auth_dto.dart';

class FirebaseAuthRepositoryImpl implements IAuthRepository {
  final FirebaseAuthDao _authDao;

  FirebaseAuthRepositoryImpl(this._authDao);

  @override
  Stream<AppAuth?> observeAuthState() {
    return _authDao.authStateChanges().map((user) {
      if (user == null) return null;

      return AppAuth(
        userId: user.userId,
        email: user.email,
        isVerified: user.emailVerified,
        isLogined: true,
      );
    });
  }

  @override
  Future<AppAuth> createUserWithEmailAndPassword(
      {required String email, required String password}) async {
    try {
      final dto =
          await _authDao.createUserWithEmailAndPassword(email, password);
      return _toEntity(dto);
    } catch (e) {
      throw Exception('Failed to create user: $e');
    }
  }

  @override
  Future<AppAuth> signInWithEmailAndPassword({
    required String email,
    required String password,
  }) async {
    try {
      final dto = await _authDao.signInWithEmailAndPassword(email, password);
      return _toEntity(dto).copyWith(isLogined: true);
    } catch (e) {
      throw Exception('Failed to sign in: $e');
    }
  }

  @override
  Future<void> signOut() async {
    try {
      await _authDao.signOut();
    } catch (e) {
      throw Exception('Failed to sign out: $e');
    }
  }

  @override
  Future<void> sendEmailVerification() async {
    try {
      await _authDao.sendEmailVerification();
    } catch (e) {
      throw Exception('Failed to send verification email: $e');
    }
  }

  @override
  Future<void> sendPasswordResetEmail({required String email}) {
    try {
      return _authDao.sendPasswordResetEmail(email: email);
    } catch (e) {
      throw Exception('Failed to send password reset email: $e');
    }
  }

  /// DTO → Domain Entity への変換
  AppAuth _toEntity(AuthDTO dto) {
    return AppAuth(
      userId: dto.userId,
      email: dto.email,
      isVerified: dto.emailVerified,
      //isLogined: false, // デフォルトは false、必要に応じて呼び出し側で上書き
    );
  }
}
