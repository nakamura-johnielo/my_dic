import 'package:my_dic/core/shared/enums/auth/provider_type.dart';

/// SDK-free authentication data passed from infrastructure to application.
final class AuthDTO {
  const AuthDTO({
    required this.accountId,
    required this.isVerified,
    this.email,
    this.provider = ProviderType.unknown,
  });

  final String accountId;
  final String? email;
  final bool isVerified;
  final ProviderType provider;
}
