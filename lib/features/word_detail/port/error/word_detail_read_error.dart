import 'package:my_dic/core/shared/errors/app_error.dart';
import 'package:my_dic/features/catalog/port/catalog.dart' show CatalogWordRef;

/// WordDetail の主要投影を信頼できなくする失敗です。
sealed class WordDetailReadError extends AppError {
  const WordDetailReadError({
    required super.message,
    required super.code,
    super.originalError,
    super.stackTrace,
  });
}

final class WordDetailNotFoundError extends WordDetailReadError {
  WordDetailNotFoundError({
    required this.word,
    String? message,
    super.originalError,
    super.stackTrace,
  }) : super(
          message: message ?? 'Word detail not found: $word',
          code: 'WORD_DETAIL_NOT_FOUND',
        );

  final CatalogWordRef word;
}

final class WordDetailDataUnavailableError extends WordDetailReadError {
  const WordDetailDataUnavailableError({
    String message = 'Word detail data is unavailable',
    super.originalError,
    super.stackTrace,
  }) : super(message: message, code: 'WORD_DETAIL_DATA_UNAVAILABLE');
}

final class WordDetailDataCorruptedError extends WordDetailReadError {
  const WordDetailDataCorruptedError({
    String message = 'Word detail data is corrupted',
    super.originalError,
    super.stackTrace,
  }) : super(message: message, code: 'WORD_DETAIL_DATA_CORRUPTED');
}

enum WordDetailContractMismatchKind { identity, direction }

/// プロバイダーが要求されたコントラクトを満たさない値を返しました。
final class WordDetailContractMismatchError extends WordDetailReadError {
  WordDetailContractMismatchError({
    required this.kind,
    required this.requestedWord,
    this.actualWord,
    String? message,
    super.originalError,
    super.stackTrace,
  }) : super(
          message: message ??
              'Word detail ${kind.name} does not match the request: '
                  '$requestedWord',
          code: 'WORD_DETAIL_CONTRACT_MISMATCH',
        );

  final WordDetailContractMismatchKind kind;
  final CatalogWordRef requestedWord;
  final CatalogWordRef? actualWord;
}

final class WordDetailUnexpectedReadError extends WordDetailReadError {
  const WordDetailUnexpectedReadError({
    String message = 'Unexpected WordDetail read failure',
    super.originalError,
    super.stackTrace,
  }) : super(message: message, code: 'WORD_DETAIL_UNEXPECTED_READ');
}
