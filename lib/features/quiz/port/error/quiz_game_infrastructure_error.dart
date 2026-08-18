import 'package:my_dic/core/shared/errors/app_error.dart';

/// A failure while reading Quiz-owned persisted data.
final class QuizGameDatabaseError extends AppError {
  const QuizGameDatabaseError({
    required this.operation,
    required super.originalError,
    required super.stackTrace,
  }) : super(
          code: 'QUIZ_GAME_DATABASE_FAILURE',
          message: 'Quiz game database read failed: $operation',
        );

  final String operation;
}

/// A failure while opening a bundled Quiz asset.
final class QuizGameAssetError extends AppError {
  const QuizGameAssetError({
    required this.assetPath,
    required super.originalError,
    required super.stackTrace,
  }) : super(
          code: 'QUIZ_GAME_ASSET_FAILURE',
          message: 'Quiz game asset read failed: $assetPath',
        );

  final String assetPath;
}

/// A bundled Quiz asset whose JSON value does not match its wire contract.
final class QuizGameDataCorruptionError extends AppError {
  const QuizGameDataCorruptionError({
    required this.assetPath,
    required this.reason,
    required super.originalError,
    required super.stackTrace,
  }) : super(
          code: 'QUIZ_GAME_DATA_CORRUPTION',
          message: 'Quiz game asset data is corrupted at $assetPath: $reason',
        );

  final String assetPath;
  final String reason;
}
