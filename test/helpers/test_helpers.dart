// Test helper utilities for creating test fixtures and common test data.

import 'package:my_dic/features/auth/port/auth.dart';

/// Create a test Auth identity with default values.
AuthIdentity createTestAuth({
  String userId = 'test-user-123',
  String? email = 'test@example.com',
  bool isVerified = true,
}) {
  return AuthIdentity(
    accountId: userId,
    email: email,
    provider: AuthProvider.email,
    emailVerified: isVerified,
  );
}
