import 'package:my_dic/core/shared/utils/result.dart';
import 'package:my_dic/core/shared/value_objects/field_update.dart';
import 'package:my_dic/features/catalog/port/catalog.dart';
import 'package:my_dic/features/word_status/port/model/word_status.dart';

/// 内部の永続化境界です。コンシューマー向けのポートではありません。
abstract interface class WordStatusRepository {
  Set<CatalogId> get supportedCatalogs;

  Future<Result<WordStatus?>> get(
    CatalogWordRef word, {
    required String accountId,
  });

  Stream<WordStatus> watch(
    CatalogWordRef word, {
    required String accountId,
  });

  /// 存在するすべての行を読み取ります。存在しない物理行は省略します。
  Future<Result<Map<CatalogWordRef, WordStatus>>> getBatch(
    Iterable<CatalogWordRef> words, {
    required String accountId,
  });

  Future<Result<WordStatus>> update(
    CatalogWordRef word, {
    required FieldUpdate<bool> isLearned,
    required FieldUpdate<bool> isBookmarked,
    required FieldUpdate<bool> hasNote,
    required DateTime updatedAt,
    required String? accountId,
  });
}
