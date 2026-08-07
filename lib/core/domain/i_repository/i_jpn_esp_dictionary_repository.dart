import 'package:my_dic/core/domain/entity/jpn_esp/jpn_esp_dictionary.dart';
import 'package:my_dic/core/shared/utils/result.dart';

abstract class IJpnEspDictionaryRepository {
  Future<Result<List<JpnEspDictionary>>> getDictionaryByWordId(int wordId);
}
