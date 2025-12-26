import 'package:my_dic/core/shared/errors/app_error.dart';

/// データベースエラー
class DatabaseError extends AppError {
  DatabaseError({
    required super.message,
    String? code,
    super.originalError,
    super.stackTrace,
  }) : super(
          code: code ?? 'DATABASE_ERROR',
        );
}

/// ネットワークエラー
class NetworkError extends AppError {
  final int? statusCode;

  NetworkError({
    required super.message,
    this.statusCode,
    String? code,
    super.originalError,
    super.stackTrace,
  }) : super(
          code: code ?? 'NETWORK_ERROR',
        );
}

/// Firebase エラー
class FirebaseError extends AppError {
  FirebaseError({
    required super.message,
    String? code,
    super.originalError,
    super.stackTrace,
  }) : super(
          code: code ?? 'FIREBASE_ERROR',
        );
}

/// キャッシュエラー
class CacheError extends AppError {
  CacheError({
    required super.message,
    String? code,
    super.originalError,
    super.stackTrace,
  }) : super(
          code: code ?? 'CACHE_ERROR',
        );
}
