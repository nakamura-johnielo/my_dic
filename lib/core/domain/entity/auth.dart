class AppAuth {
  final String accountId;
  final String? email;
  final String? userName;
  final bool isLogined;
  final String? authProvider;
  final bool isVerified;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  AppAuth({
    required this.accountId,
    this.email,
    this.userName,
    this.isLogined = false,
    this.authProvider,
    this.isVerified = false,
    this.createdAt,
    this.updatedAt,
  });

  AppAuth copyWith({
    String? userId,
    String? email,
    String? userName,
    bool? isLogined,
    String? authProvider,
    bool? isVerified,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return AppAuth(
      accountId: userId ?? this.accountId,
      email: email ?? this.email,
      userName: userName ?? this.userName,
      isLogined: isLogined ?? this.isLogined,
      authProvider: authProvider ?? this.authProvider,
      isVerified: isVerified ?? this.isVerified,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  String toString() {
    return 'AppAuth(userId: $accountId, email: $email, isLogined: $isLogined, isVerified: $isVerified)';
  }
}
