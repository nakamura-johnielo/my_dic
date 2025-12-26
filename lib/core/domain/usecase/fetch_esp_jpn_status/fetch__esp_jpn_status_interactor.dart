import 'package:my_dic/core/domain/usecase/fetch_esp_jpn_status/fetch_esp_jpn_status_usecase.dart';
import 'package:my_dic/core/domain/entity/word/esp_word_status.dart';
import 'package:my_dic/core/domain/i_repository/i_word_status_repository.dart';
import 'package:my_dic/core/shared/utils/result.dart';

class FetchEspJpnWordStatusInteractor implements FetchEspJpnWordStatusUsecase {
  final IWordStatusRepository repository;
  FetchEspJpnWordStatusInteractor(this.repository);

  @override
  Future<Result<WordStatus>> execute(int wordId) async {
    final result = await repository.getWordStatusById(wordId);
    if (result.isFailure) {
      return Result.failure(result.errorOrNull!);
    }

    return result.map((data) => data ?? WordStatus(wordId: wordId));
  }

  @override
  Stream<WordStatus> watch(int wordId) {
    return repository.watchWordStatusById(wordId);
  }
}
