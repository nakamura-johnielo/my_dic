import 'package:my_dic/core/shared/errors/app_error.dart';

/// 主要な Search ページの読み込みを妨げる失敗の基底型です。
sealed class SearchReadError extends AppError {
  const SearchReadError({
    required super.message,
    required super.code,
    super.originalError,
    super.stackTrace,
  });
}

final class SearchDataUnavailableError extends SearchReadError {
  const SearchDataUnavailableError({
    String message = 'Search data is unavailable',
    super.originalError,
    super.stackTrace,
  }) : super(message: message, code: 'SEARCH_DATA_UNAVAILABLE');
}

final class SearchUnexpectedReadError extends SearchReadError {
  const SearchUnexpectedReadError({
    String message = 'Unexpected Search read failure',
    super.originalError,
    super.stackTrace,
  }) : super(message: message, code: 'SEARCH_UNEXPECTED_READ');
}
