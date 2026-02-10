import 'package:firebase_auth/firebase_auth.dart';
import 'package:my_dic/core/shared/utils/logger.dart';
import 'package:my_dic/features/auth/data/dto/auth_dto.dart';

class FirebaseAuthDao {
  final FirebaseAuth _auth;
  FirebaseAuthDao(this._auth);

  Stream<AuthDTO?> authStateChanges() {
    //TODO　ping追加
    // authStateChangesにするかuserChangesにするかは要検討
    return _auth.userChanges().map(
      (user) {
        AppLogger.print("!!!!!!auth state changed!!!!");

        final res = user != null ? AuthDTO.fromFirebaseUser(user) : null;
        user != null ? _printBatch(user) : AppLogger.print("user null");
        return res;
      },
    );
  }

  void _printBatch(User user) {
    AppLogger.print("  emailVerified: ${user.emailVerified}");
    AppLogger.print("  provider: ${user.providerData}");
    AppLogger.print("  refreshtoken: ${user.refreshToken}");
  }

  Future<AuthDTO?> createUserWithEmailAndPassword(
      String email, String password) async {
    final userCredential = await _auth.createUserWithEmailAndPassword(
        email: email, password: password);

    if (userCredential.user == null) return null;
    return AuthDTO.fromFirebaseUserCredential(userCredential);
  }

  Future<AuthDTO?> signInWithEmailAndPassword(
      String email, String password) async {
    final userCredential = await _auth.signInWithEmailAndPassword(
        email: email, password: password);
    AppLogger.print("+++++++++++++++++++siginin 1");
    if (userCredential.user != null) {
      _printBatch(userCredential.user!);
    }
    if (userCredential.user == null) return null;
    return AuthDTO.fromFirebaseUserCredential(userCredential);
  }

  Future<void> signOut() {
    return _auth.signOut();
  }

  Future<void> sendEmailVerification() async {
    final user = _auth.currentUser;
    if (user != null && !user.emailVerified) {
      await user.sendEmailVerification();
    }
  }

  Future<void> sendPasswordResetEmail({required String email}) {
    return _auth.sendPasswordResetEmail(email: email);
  }

  Future<AuthDTO?> getCurrentAuth() async {
    if (_auth.currentUser == null) return null;
    return AuthDTO.fromFirebaseUser(_auth.currentUser!);
  }
}
