import 'package:my_dic/core/shared/utils/result.dart';
import 'package:my_dic/features/catalog/internal/domain/dictionary_entry/jpn_esp_dictionary.dart';

/// 日本語からスペイン語へのエントリに対する Catalog 内部の永続化境界。
abstract interface class IJpnEspDictionaryRepository {
  Future<Result<List<JpnEspDictionary>>> getDictionaryByWordId(int id);
}
