import 'package:my_dic/core/shared/utils/result.dart';
import 'package:my_dic/features/catalog/internal/domain/word/jpn_esp_word.dart';

abstract class IJpnEspWordRepository {
  Future<Result<List<JpnEspWord>>> getWordsByWord(
    String word,
    int size,
    int page,
  );
}
