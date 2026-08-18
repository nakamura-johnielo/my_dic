import 'package:my_dic/core/shared/errors/app_error.dart';
import 'package:my_dic/features/catalog/port/catalog.dart';

enum WordStatusReadFailureKind {
  unsupportedCatalog,
  storage,
  corruptData,
  unexpected,
}

final class WordStatusReadError extends AppError {
  const WordStatusReadError._({
    required this.kind,
    required super.message,
    this.catalogId,
    required super.code,
  });

  const WordStatusReadError.unsupportedCatalog(CatalogId catalogId)
      : this._(
          kind: WordStatusReadFailureKind.unsupportedCatalog,
          message: 'The Catalog dataset is not supported by WordStatus.',
          catalogId: catalogId,
          code: 'WORD_STATUS_UNSUPPORTED_CATALOG',
        );

  const WordStatusReadError.storage()
      : this._(
          kind: WordStatusReadFailureKind.storage,
          message: 'Word status could not be read.',
          code: 'WORD_STATUS_READ_STORAGE',
        );

  const WordStatusReadError.corruptData()
      : this._(
          kind: WordStatusReadFailureKind.corruptData,
          message: 'Stored word status is invalid.',
          code: 'WORD_STATUS_READ_CORRUPT_DATA',
        );

  const WordStatusReadError.unexpected()
      : this._(
          kind: WordStatusReadFailureKind.unexpected,
          message: 'Word status could not be read.',
          code: 'WORD_STATUS_READ_UNEXPECTED',
        );

  final WordStatusReadFailureKind kind;
  final CatalogId? catalogId;
}

enum WordStatusWriteFailureKind {
  unsupportedCatalog,
  storage,
  corruptData,
  unexpected,
}

final class WordStatusWriteError extends AppError {
  const WordStatusWriteError._({
    required this.kind,
    required super.message,
    this.catalogId,
    required super.code,
  });

  const WordStatusWriteError.unsupportedCatalog(CatalogId catalogId)
      : this._(
          kind: WordStatusWriteFailureKind.unsupportedCatalog,
          message: 'The Catalog dataset is not supported by WordStatus.',
          catalogId: catalogId,
          code: 'WORD_STATUS_UNSUPPORTED_CATALOG',
        );

  const WordStatusWriteError.storage()
      : this._(
          kind: WordStatusWriteFailureKind.storage,
          message: 'Word status could not be updated.',
          code: 'WORD_STATUS_WRITE_STORAGE',
        );

  const WordStatusWriteError.corruptData()
      : this._(
          kind: WordStatusWriteFailureKind.corruptData,
          message: 'Stored word status is invalid.',
          code: 'WORD_STATUS_WRITE_CORRUPT_DATA',
        );

  const WordStatusWriteError.unexpected()
      : this._(
          kind: WordStatusWriteFailureKind.unexpected,
          message: 'Word status could not be updated.',
          code: 'WORD_STATUS_WRITE_UNEXPECTED',
        );

  final WordStatusWriteFailureKind kind;
  final CatalogId? catalogId;
}
