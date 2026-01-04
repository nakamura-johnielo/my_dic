/// Test helper utilities for creating test fixtures and common test data

import 'package:my_dic/core/domain/entity/auth.dart';

/// Create a test AppAuth instance with default values
AppAuth createTestAuth({
  String userId = 'test-user-123',
  String? email = 'test@example.com',
  String? userName = 'Test User',
  bool isLogined = true,
  String? authProvider = 'email',
  bool isVerified = true,
  DateTime? createdAt,
  DateTime? updatedAt,
}) {
  return AppAuth(
    accountId: userId,
    email: email,
    userName: userName,
    isLogined: isLogined,
    authProvider: authProvider,
    isVerified: isVerified,
    createdAt: createdAt ?? DateTime(2025, 1, 1),
    updatedAt: updatedAt ?? DateTime(2025, 1, 1),
  );
}
