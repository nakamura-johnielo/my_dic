
import 'package:my_dic/features/esp_jpn_word_status/domain/esp_word_status.dart';
import 'package:my_dic/features/esp_jpn_word_status/domain/i_word_status_repository.dart';
import 'package:my_dic/features/esp_jpn_word_status/domain/usecase/watch/i_watch_esp_jpn_word_status_usecase.dart';

class WatchEspJpnWordStatusInteractor implements IWatchEspJpnWordStatusUsecase{
  final IWordStatusRepository _repository;
  
  WatchEspJpnWordStatusInteractor(this._repository);
  
  @override
  Stream<WordStatus> execute(int wordId) {
    return _repository.watchWordStatusById(wordId);
  }
}