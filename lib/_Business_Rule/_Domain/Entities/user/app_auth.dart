class AppAuth {
  final String userId;
  final String? email;
  final String? userName;
  final bool isLogined;
  final String? authProvider;
  final bool isVerified;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  AppAuth({
    required this.userId,
    this.email,
    this.userName,
    this.isLogined = false,
    this.authProvider,
    this.isVerified = false,
    this.createdAt,
    this.updatedAt,
  });
}
