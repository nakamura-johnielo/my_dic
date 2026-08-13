import 'package:my_dic/core/shared/utils/result.dart';
import 'package:my_dic/features/catalog/port/catalog_word_ref.dart';
import 'package:my_dic/features/catalog/port/model/catalog_entry_detail.dart';

/// Reads direction-specific dictionary detail from a Catalog dataset.
abstract interface class CatalogQueryPort {
  Future<Result<CatalogEntryDetail>> getEntryDetail(CatalogWordRef word);
}
