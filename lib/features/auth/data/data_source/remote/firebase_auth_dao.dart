import 'package:firebase_auth/firebase_auth.dart';
import 'package:my_dic/features/auth/data/dto/auth_dto.dart';

class FirebaseAuthDao {
  final FirebaseAuth _auth;
  FirebaseAuthDao(this._auth);

  Stream<AuthDTO?> authStateChanges() {
    return _auth.userChanges().map(
      (user) {
        print("!!!!!!auth state changed!!!!");

        final res = user != null ? AuthDTO.fromFirebaseUser(user) : null;
        user != null ? _printBatch(user) : print("user null");
        return res;
      },
    );

    return _auth.authStateChanges().map(
      (user) {
        print("!!!!!!auth state changed!!!!");

        final res = user != null ? AuthDTO.fromFirebaseUser(user) : null;
        user != null ? _printBatch(user) : print("user nullr");
        return res;
      },
    );
  }

  void _printBatch(User user) {
    print("  emailVerified: ${user.emailVerified}");
    print("  provider: ${user.providerData}");
    print("  refreshtoken: ${user.refreshToken}");
    //print("refreshtoken: ${user.}");
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
    print("+++++++++++++++++++siginin 1");
    if (userCredential.user != null) {
      //await userCredential.user!.reload(); // Ensure user state is refreshed
      _printBatch(userCredential.user!);
      //await userCredential.user!.reload();
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
}
