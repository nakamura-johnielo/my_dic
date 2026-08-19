import 'package:my_dic/core/shared/utils/result.dart';
import 'package:my_dic/features/catalog/internal/domain/dictionary_entry/esp_jpn_dictionary.dart';

/// スペイン語から日本語へのエントリに対する Catalog 内部の永続化境界。
abstract interface class IEspJpnDictionaryRepository {
  Future<Result<List<EspJpnDictionary>>> getDictionaryByWordId(int id);
}
