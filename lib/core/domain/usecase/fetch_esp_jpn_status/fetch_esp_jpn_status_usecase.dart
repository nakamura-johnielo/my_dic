


import 'package:my_dic/core/domain/entity/word/esp_word_status.dart';

abstract class FetchEspJpnWordStatusUsecase {
  Future<WordStatus> execute(int wordId);
  Stream<WordStatus> watch(int wordId);
}
