
import 'package:my_dic/features/jpn_esp_word_status/domain/jpn_esp_word_status.dart';

abstract class IWatchJpnEspWordStatusUsecase {
  Stream<JpnEspWordStatus> execute(int wordId);
}
