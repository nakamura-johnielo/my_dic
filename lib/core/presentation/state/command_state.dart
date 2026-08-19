import 'package:my_dic/core/shared/errors/app_error.dart';

/// ユーザー起点の1つの操作におけるライフサイクル。
sealed class CommandState {
  const CommandState();

  const factory CommandState.idle() = CommandIdle;
  const factory CommandState.submitting(String operation) = CommandSubmitting;
  const factory CommandState.succeeded(String operation) = CommandSucceeded;
  const factory CommandState.failed(String operation, AppError error) =
      CommandFailed;

  String? get operation => switch (this) {
        CommandIdle() => null,
        CommandSubmitting(operation: final operation) => operation,
        CommandSucceeded(operation: final operation) => operation,
        CommandFailed(operation: final operation) => operation,
      };

  AppError? get errorOrNull => switch (this) {
        CommandFailed(error: final error) => error,
        _ => null,
      };

  bool get isIdle => this is CommandIdle;
  bool get isSubmitting => this is CommandSubmitting;
  bool get isSucceeded => this is CommandSucceeded;
  bool get isFailed => this is CommandFailed;
}

final class CommandIdle extends CommandState {
  const CommandIdle();
}

final class CommandSubmitting extends CommandState {
  const CommandSubmitting(this.operation);

  @override
  final String operation;
}

final class CommandSucceeded extends CommandState {
  const CommandSucceeded(this.operation);

  @override
  final String operation;
}

final class CommandFailed extends CommandState {
  const CommandFailed(this.operation, this.error);

  @override
  final String operation;
  final AppError error;
}
