import 'package:firebase_auth/firebase_auth.dart';
import 'package:my_dic/features/auth/internal/application/model/auth_dto.dart';
import 'package:my_dic/features/auth/internal/infrastructure/firebase/firebase_auth_mapper.dart';

class FirebaseAuthDao {
  final FirebaseAuth _auth;
  FirebaseAuthDao(this._auth);

  Stream<AuthDTO?> authStateChanges() {
    //TODO　ping追加
    // authStateChangesにするかuserChangesにするかは要検討
    return _auth.userChanges().map(
      (user) {
        return user != null ? FirebaseAuthMapper.fromFirebaseUser(user) : null;
      },
    );
  }

  Future<AuthDTO?> createUserWithEmailAndPassword(
      String email, String password) async {
    final userCredential = await _auth.createUserWithEmailAndPassword(
        email: email, password: password);

    if (userCredential.user == null) return null;
    return FirebaseAuthMapper.fromFirebaseUserCredential(userCredential);
  }

  Future<AuthDTO?> signInWithEmailAndPassword(
      String email, String password) async {
    final userCredential = await _auth.signInWithEmailAndPassword(
        email: email, password: password);
    if (userCredential.user == null) return null;
    return FirebaseAuthMapper.fromFirebaseUserCredential(userCredential);
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
    return FirebaseAuthMapper.fromFirebaseUser(_auth.currentUser!);
  }

  Future<AuthDTO?> reloadCurrentAuth() async {
    final user = _auth.currentUser;
    if (user == null) return null;

    await user.reload();
    final refreshedUser = _auth.currentUser;
    return refreshedUser == null
        ? null
        : FirebaseAuthMapper.fromFirebaseUser(refreshedUser);
  }
}
