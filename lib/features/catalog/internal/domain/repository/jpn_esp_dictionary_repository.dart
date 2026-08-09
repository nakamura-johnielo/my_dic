import 'package:my_dic/core/shared/utils/result.dart';
import 'package:my_dic/features/catalog/internal/domain/dictionary_entry/jpn_esp_dictionary.dart';

abstract class IJpnEspDictionaryRepository {
  Future<Result<List<JpnEspDictionary>>> getDictionaryByWordId(int wordId);
}
