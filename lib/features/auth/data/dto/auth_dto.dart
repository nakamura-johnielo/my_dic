import 'package:firebase_auth/firebase_auth.dart';

/// Firebase Authentication の生データを表すDTO
/// Data層内でのみ使用し、Domain層の AppAuth へ変換される
class AuthDTO {
  final String userId;
  final String? email;
  final bool emailVerified;

  AuthDTO({
    required this.userId,
    this.email,
    required this.emailVerified,
  });

  // データ不正 -> exception
  factory AuthDTO.fromFirebaseUserCredential(UserCredential userCredential) {
    final user = userCredential.user;

    if (user == null) {
      throw Exception('UserCredential.user is null');
    }

    if (user.uid.isEmpty) {
      throw Exception('User ID is empty');
    }

    return AuthDTO(
      userId: user.uid,
      email: user.email, // null 許容（匿名認証対応）
      emailVerified: user.emailVerified,
    );
  }

  /// User から生成（authStateChanges 監視時）
  factory AuthDTO.fromFirebaseUser(User user) {
    if (user.uid.isEmpty) {
      throw Exception('User ID is empty');
    }

    return AuthDTO(
      userId: user.uid,
      email: user.email,
      emailVerified: user.emailVerified,
    );
  }
}
