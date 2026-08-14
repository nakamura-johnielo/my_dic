import 'package:my_dic/core/shared/utils/result.dart';
import 'package:my_dic/features/catalog/internal/domain/dictionary_entry/esp_jpn_dictionary.dart';

/// Catalog-internal persistence boundary for Spanish-to-Japanese entries.
abstract interface class IEspJpnDictionaryRepository {
  Future<Result<List<EspJpnDictionary>>> getDictionaryByWordId(int id);
}
