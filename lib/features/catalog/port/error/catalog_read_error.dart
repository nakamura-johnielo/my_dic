import 'package:my_dic/core/shared/errors/app_error.dart';
import 'package:my_dic/features/catalog/port/catalog_word_ref.dart';

/// Base class for failures produced at the Catalog reader boundary.
sealed class CatalogReadError extends AppError {
  const CatalogReadError({
    required super.message,
    required super.code,
    super.originalError,
    super.stackTrace,
  });
}

final class CatalogEntryNotFoundError extends CatalogReadError {
  CatalogEntryNotFoundError({
    required this.word,
    String? message,
    super.originalError,
    super.stackTrace,
  }) : super(
          message: message ?? 'Catalog entry not found: $word',
          code: 'CATALOG_ENTRY_NOT_FOUND',
        );

  final CatalogWordRef word;
}

final class CatalogDataUnavailableError extends CatalogReadError {
  const CatalogDataUnavailableError({
    String message = 'Catalog data is unavailable',
    super.originalError,
    super.stackTrace,
  }) : super(message: message, code: 'CATALOG_DATA_UNAVAILABLE');
}

final class CatalogDataCorruptedError extends CatalogReadError {
  const CatalogDataCorruptedError({
    String message = 'Catalog data is corrupted',
    super.originalError,
    super.stackTrace,
  }) : super(message: message, code: 'CATALOG_DATA_CORRUPTED');
}

final class CatalogUnexpectedReadError extends CatalogReadError {
  const CatalogUnexpectedReadError({
    String message = 'Unexpected Catalog read failure',
    super.originalError,
    super.stackTrace,
  }) : super(message: message, code: 'CATALOG_UNEXPECTED_READ');
}
