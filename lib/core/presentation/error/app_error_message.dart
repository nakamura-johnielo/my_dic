import 'package:my_dic/core/shared/errors/app_error.dart';
import 'package:my_dic/core/shared/errors/domain_errors.dart';
import 'package:my_dic/core/shared/errors/infrastructure_errors.dart';

/// User-facing copy derived from a typed [AppError].
///
/// The original diagnostic error remains in state; this value must only be
/// created at the presentation boundary.
class AppErrorMessage {
  const AppErrorMessage(this.text);

  final String text;

  String get message => text;

  static AppErrorMessage from(AppError error) => AppErrorMessage(
        switch (error) {
          ValidationError() => '入力内容を確認してください。',
          UnauthorizedError() => 'ログインが必要です。',
          NotFoundError() => '必要な情報が見つかりませんでした。',
          NetworkError() => '通信に失敗しました。接続を確認してもう一度お試しください。',
          DatabaseError() || CacheError() => 'データを読み込めませんでした。もう一度お試しください。',
          FirebaseError() => 'サービスに接続できませんでした。もう一度お試しください。',
          _ => _messageForCode(error.code),
        },
      );

  static AppErrorMessage fromError(AppError error) => from(error);
  static AppErrorMessage forError(AppError error) => from(error);

  static String _messageForCode(String? code) => switch (code) {
        'VALIDATION_ERROR' => '入力内容を確認してください。',
        'UNAUTHORIZED' => 'ログインが必要です。',
        'NOT_FOUND' ||
        'USER_NOT_FOUND' ||
        'DEVICE_ID_NOT_FOUND' =>
          '必要な情報が見つかりませんでした。',
        'NETWORK_ERROR' => '通信に失敗しました。接続を確認してもう一度お試しください。',
        'DATABASE_ERROR' || 'CACHE_ERROR' => 'データを読み込めませんでした。もう一度お試しください。',
        'FIREBASE_ERROR' => 'サービスに接続できませんでした。もう一度お試しください。',
        _ => '予期しないエラーが発生しました。もう一度お試しください。',
      };
}

String appErrorMessage(AppError error) => AppErrorMessage.from(error).text;
