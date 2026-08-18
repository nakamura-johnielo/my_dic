import 'package:my_dic/core/shared/utils/result.dart';
import 'package:my_dic/features/catalog/internal/domain/dictionary_entry/jpn_esp_dictionary.dart';

/// Catalog-internal persistence boundary for Japanese-to-Spanish entries.
abstract interface class IJpnEspDictionaryRepository {
  Future<Result<List<JpnEspDictionary>>> getDictionaryByWordId(int id);
}
