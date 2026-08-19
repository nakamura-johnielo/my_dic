import 'package:my_dic/core/shared/errors/app_error.dart';

/// Quiz 所有の永続化データ読み取り中に発生する失敗。
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

/// バンドル済み Quiz アセットを開く際に発生する失敗。
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

/// JSON 値がワイヤ契約に適合しない、バンドル済み Quiz アセット。
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
