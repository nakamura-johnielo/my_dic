import 'package:flutter_test/flutter_test.dart';
import 'package:my_dic/core/presentation/error/app_error_message.dart';
import 'package:my_dic/core/shared/errors/app_error.dart';
import 'package:my_dic/core/shared/errors/domain_errors.dart';
import 'package:my_dic/core/shared/errors/infrastructure_errors.dart';

void main() {
  test('maps typed AppErrors without exposing diagnostic messages', () {
    final error = ValidationError(message: 'internal validation detail');

    expect(AppErrorMessage.from(error).text, '入力内容を確認してください。');
    expect(
        appErrorMessage(error), isNot(contains('internal validation detail')));
  });

  test('maps known error codes and falls back safely for unknown errors', () {
    final networkByCode =
        _TestError(message: 'internal', code: 'NETWORK_ERROR');
    final unknown = _TestError(message: 'internal', code: 'SOMETHING_NEW');

    expect(AppErrorMessage.from(networkByCode).text, contains('通信に失敗'));
    expect(AppErrorMessage.from(unknown).text, contains('予期しないエラー'));
  });

  test('maps infrastructure errors by type', () {
    final error = DatabaseError(message: 'database detail');

    expect(AppErrorMessage.from(error).text, contains('データを読み込めません'));
  });
}

class _TestError extends AppError {
  const _TestError({required super.message, super.code});
}
