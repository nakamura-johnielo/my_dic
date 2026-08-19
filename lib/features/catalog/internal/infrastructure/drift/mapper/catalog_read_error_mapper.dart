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

  /// 永続化値の変換中に発生した失敗を分類する。想定される値・形式の失敗は Catalog
  /// データの不備を示す。その他の例外はリーダーの不具合であり、データ破損として
  /// 報告してはならない。
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
