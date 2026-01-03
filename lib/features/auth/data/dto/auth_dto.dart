import 'package:firebase_auth/firebase_auth.dart';
import 'package:my_dic/core/shared/enums/auth/provider_type.dart';

/// Firebase Authentication の生データを表すDTO
/// Data層内でのみ使用し、Domain層の AppAuth へ変換される
class AuthDTO {
  final String accountId;
  final String? email;
  final bool isVerified;
  final ProviderType provider; 

  AuthDTO( {
    required this.accountId,
    this.email,
    required this.isVerified,
    this.provider=ProviderType.unknown,
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

    final provider=userCredential.credential?.providerId;

    return AuthDTO(
      accountId: user.uid,
      email: user.email, // null 許容（匿名認証対応）
      isVerified: user.emailVerified,
      provider: ProviderTypeExtension.fromFirebaseProviderId( provider)
    );
  }

  /// User から生成（authStateChanges 監視時）
  factory AuthDTO.fromFirebaseUser(User user) {
    if (user.uid.isEmpty) {
      throw Exception('User ID is empty');
    }

    return AuthDTO(
      accountId: user.uid,
      email: user.email,
      isVerified: user.emailVerified,
    );
  }
}
