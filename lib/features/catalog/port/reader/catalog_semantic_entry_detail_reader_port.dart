import 'package:my_dic/core/shared/utils/result.dart';
import 'package:my_dic/features/catalog/port/catalog_word_ref.dart';
import 'package:my_dic/features/catalog/port/model/catalog_semantic_entry_detail.dart';

abstract interface class CatalogSemanticEntryDetailQueryPort {
  Future<Result<CatalogSemanticEntryDetail>> readSemanticEntryDetail(
    CatalogWordRef word,
  );
}
