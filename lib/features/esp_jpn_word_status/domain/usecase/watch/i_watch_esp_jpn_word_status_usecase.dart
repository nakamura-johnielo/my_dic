
import 'package:my_dic/features/esp_jpn_word_status/domain/esp_word_status.dart';

abstract class IWatchEspJpnWordStatusUsecase {
  Stream<WordStatus> execute(int wordId);
}