import 'package:my_dic/_Business_Rule/_Domain/Entities/user/app_auth.dart';
import 'package:my_dic/_Business_Rule/_Domain/Entities/user/user.dart';
import 'package:my_dic/_Business_Rule/_Domain/Repository_I/i_auth_repository.dart';
import 'package:my_dic/_Framework_Driver/remote/firebase/DAO/auth.dart';

class FirebaseAuthRepository implements IAuthRepository {
  final FirebaseAuthDao _authDao;
  //final UserProfileDao _userProfileDao;
  FirebaseAuthRepository(this._authDao /*, this._userProfileDao*/);

  @override
  Stream<AppAuth?> observeAuthState() {
    return _authDao.authStateChanges().map((user) {
      print("=====================================");
      print("AUTH OBSERVE");
      if (user == null) return null;
      print("user id: ${user.uid}, isVerified: ${user.emailVerified}");

      return AppAuth(
        userId: user.uid,
        email: user.email,
        isVerified: user.emailVerified,
        isLogined: true,
      );
    });
  }

  @override
  Future<AppAuth> createUserWithEmailAndPassword(
      {required String email, required String password}) async {
    final userCredential =
        await _authDao.createUserWithEmailAndPassword(email, password);
    final user = userCredential.user;
    if (user == null) {
      throw Exception('User creation failed');
    }
    return AppAuth(
      userId: user.uid,
      email: user.email,
      isVerified: user.emailVerified,
    );
  }

  @override
  Future<AppAuth> signInWithEmailAndPassword({
    required String email,
    required String password,
  }) async {
    final userCredential =
        await _authDao.signInWithEmailAndPassword(email, password);
    final user = userCredential.user;
    if (user == null) {
      throw Exception('Sign in failed');
    }
    return AppAuth(
      userId: user.uid,
      email: user.email,
      isVerified: user.emailVerified,
    );
  }

  @override
  Future<void> signOut() async {
    return await _authDao.signOut();
  }

  @override
  Future<void> sendEmailVerification() async {
    return await _authDao.sendEmailVerification();
  }

  @override
  Future<void> sendPasswordResetEmail({required String email}) {
    return _authDao.sendPasswordResetEmail(email: email);
  }
}
