import 'package:my_dic/core/shared/utils/result.dart';
import 'package:my_dic/core/shared/value_objects/field_update.dart';
import 'package:my_dic/features/catalog/port/catalog_word_ref.dart';
import 'package:my_dic/features/word_status/port/word_status.dart';

abstract interface class WordStatusRepository {
  Future<Result<WordStatus?>> get(
    CatalogWordRef word, {
    required String accountId,
  });

  Stream<WordStatus> watch(CatalogWordRef word, {required String accountId});

  Future<Result<WordStatus>> update(
    CatalogWordRef word, {
    required FieldUpdate<bool> isLearned,
    required FieldUpdate<bool> isBookmarked,
    required FieldUpdate<bool> hasNote,
    required DateTime updatedAt,
    required String? accountId,
  });
}
