import 'package:my_dic/core/shared/utils/result.dart';
import 'package:my_dic/features/catalog/internal/domain/dictionary_entry/esp_jpn_dictionary.dart';

abstract class IEsjDictionaryRepository {
  Future<Result<List<EspJpnDictionary>>> getDictionaryByWordId(int id);
}
