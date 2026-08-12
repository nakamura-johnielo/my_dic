import 'package:my_dic/core/shared/errors/app_error.dart';
import 'package:my_dic/core/shared/errors/infrastructure_errors.dart';

/// Converts technology-specific failures at the MyWord infrastructure boundary
/// into the typed errors understood by the application and public ports.
final class MyWordInfrastructureErrorMapper {
  const MyWordInfrastructureErrorMapper._();

  static AppError database(
    Object error,
    StackTrace stackTrace, {
    required String message,
  }) =>
      error is AppError
          ? error
          : DatabaseError(
              message: message,
              originalError: error,
              stackTrace: stackTrace,
            );

  static AppError firebase(
    Object error,
    StackTrace stackTrace, {
    required String message,
  }) =>
      error is AppError
          ? error
          : FirebaseError(
              message: message,
              originalError: error,
              stackTrace: stackTrace,
            );
}
