class AuthEntity {
  final String id;
  final String? email;
  final bool emailVerified;

  AuthEntity({required this.id, this.email, required this.emailVerified});
  //: email = email ?? 'no registered';
}
