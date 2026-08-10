import 'package:firebase_auth/firebase_auth.dart';
import 'package:my_dic/core/shared/enums/auth/provider_type.dart';
import 'package:my_dic/features/auth/internal/application/auth_dto.dart';

/// Converts Firebase SDK values into the SDK-free Auth DTO.
final class FirebaseAuthMapper {
  static AuthDTO fromFirebaseUserCredential(UserCredential credential) {
    final user = credential.user;
    if (user == null) throw Exception('UserCredential.user is null');
    if (user.uid.isEmpty) throw Exception('User ID is empty');

    return AuthDTO(
      accountId: user.uid,
      email: user.email,
      isVerified: user.emailVerified,
      provider: ProviderTypeExtension.fromFirebaseProviderId(
        credential.credential?.providerId,
      ),
    );
  }

  static AuthDTO fromFirebaseUser(User user) {
    if (user.uid.isEmpty) throw Exception('User ID is empty');
    return AuthDTO(
      accountId: user.uid,
      email: user.email,
      isVerified: user.emailVerified,
    );
  }
}
