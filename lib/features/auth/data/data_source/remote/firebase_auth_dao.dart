import 'package:firebase_auth/firebase_auth.dart';
import 'package:my_dic/features/auth/data/dto/auth_dto.dart';

class FirebaseAuthDao {
  final FirebaseAuth _auth;
  FirebaseAuthDao(this._auth);

  Stream<AuthDTO?> authStateChanges() {
    return _auth.authStateChanges().map(
          (user) => user != null ? AuthDTO.fromFirebaseUser(user) : null,
        );
  }

  Future<AuthDTO> createUserWithEmailAndPassword(
      String email, String password) async {
    final userCredential = await _auth.createUserWithEmailAndPassword(
        email: email, password: password);
    return AuthDTO.fromFirebaseUserCredential(userCredential);
  }

  Future<AuthDTO> signInWithEmailAndPassword(
      String email, String password) async {
    final userCredential = await _auth.signInWithEmailAndPassword(
        email: email, password: password);
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
