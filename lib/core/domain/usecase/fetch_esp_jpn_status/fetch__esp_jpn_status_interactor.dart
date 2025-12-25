
import 'package:my_dic/core/domain/usecase/fetch_esp_jpn_status/fetch_esp_jpn_status_usecase.dart';
import 'package:my_dic/core/domain/entity/word/esp_word_status.dart';
import 'package:my_dic/core/domain/i_repository/i_word_status_repository.dart';


class FetchEspJpnWordStatusInteractor implements FetchEspJpnWordStatusUsecase {
  final IWordStatusRepository repository;
  FetchEspJpnWordStatusInteractor(this.repository);

  @override
  Future<WordStatus> execute(int wordId) async {
    return await repository.getWordStatusById(wordId);
  }
  @override
  Stream<WordStatus> watch(int wordId) {
    return repository.watchWordStatusById(wordId);
  }
}
