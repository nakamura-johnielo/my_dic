
import 'package:my_dic/features/jpn_esp_word_status/domain/jpn_esp_word_status.dart';
import 'package:my_dic/features/jpn_esp_word_status/domain/i_jpn_esp_word_status_repository.dart';
import 'package:my_dic/features/jpn_esp_word_status/domain/usecase/watch/i_watch_jpn_esp_word_status_usecase.dart';

class WatchJpnEspWordStatusInteractor implements IWatchJpnEspWordStatusUsecase{
  final IJpnEspWordStatusRepository _repository;
  
  WatchJpnEspWordStatusInteractor(this._repository);
  
  @override
  Stream<JpnEspWordStatus> execute(int wordId) {
    return _repository.watchWordStatusById(wordId);
  }
}
