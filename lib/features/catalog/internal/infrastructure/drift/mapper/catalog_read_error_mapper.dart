import 'package:my_dic/features/catalog/port/error/catalog_read_error.dart';

final class CatalogReadErrorMapper {
  const CatalogReadErrorMapper();

  CatalogReadError query(Object cause, StackTrace stackTrace) =>
      CatalogDataUnavailableError(
        originalError: cause,
        stackTrace: stackTrace,
      );

  CatalogReadError corrupted(Object cause, StackTrace stackTrace) =>
      CatalogDataCorruptedError(
        originalError: cause,
        stackTrace: stackTrace,
      );

  /// Classifies failures raised while converting persisted values. Expected
  /// value/format failures indicate bad Catalog data; other exceptions are
  /// reader defects and must not be reported as data corruption.
  CatalogReadError conversion(Object cause, StackTrace stackTrace) =>
      switch (cause) {
        FormatException() ||
        RangeError() ||
        ArgumentError() =>
          corrupted(cause, stackTrace),
        _ => unexpected(cause, stackTrace),
      };

  CatalogReadError unexpected(Object cause, StackTrace stackTrace) =>
      CatalogUnexpectedReadError(
        originalError: cause,
        stackTrace: stackTrace,
      );
}
