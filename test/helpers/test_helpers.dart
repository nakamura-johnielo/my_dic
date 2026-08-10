// Test helper utilities for creating test fixtures and common test data.

import 'package:my_dic/core/shared/enums/auth/provider_type.dart';
import 'package:my_dic/features/auth/port/app_auth.dart';

/// Create a test AppAuth instance with default values
AppAuth createTestAuth({
  String userId = 'test-user-123',
  String? email = 'test@example.com',
  bool isLogined = true,
  bool isVerified = true,
}) {
  return AppAuth(
    accountId: userId,
    email: email,
    isLogined: isLogined,
    provider: ProviderType.email,
    isAuthenticated: isVerified,
  );
}
