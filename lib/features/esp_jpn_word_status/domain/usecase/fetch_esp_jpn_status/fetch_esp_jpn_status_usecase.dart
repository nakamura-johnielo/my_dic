


import 'package:my_dic/features/esp_jpn_word_status/domain/esp_word_status.dart';
import 'package:my_dic/core/shared/utils/result.dart';

abstract class FetchEspJpnWordStatusUsecase {
  Future<Result<WordStatus>> execute(int wordId);
  Stream<WordStatus> watch(int wordId);
}
