import 'package:my_dic/Constants/Enums/feature_tag.dart';
import 'package:my_dic/_Business_Rule/Usecase/update_status/update_status_repository_input_data.dart';
import 'package:my_dic/_Business_Rule/_Domain/Entities/word/word_status.dart';
import 'package:my_dic/_Business_Rule/_Domain/Repository_I/i_esj_word_repository.dart';
import 'package:my_dic/utils/date_handler.dart';

class EsJUpdateStatusInputData {
  final int wordId;
  final Set<FeatureTag> status;
  EsJUpdateStatusInputData(this.wordId, this.status);
}

class EspJpnStatusInteractor {
  final IEsjWordRepository repository;
  EspJpnStatusInteractor(this.repository);

  Future<WordStatus> fetchWordStatus(int wordId) async {
    return await repository.getStatusById(wordId);
  }

  void updateWordStatus(EsJUpdateStatusInputData input) {
    String dateTime = getNowUTCDateHour();
    UpdateStatusRepositoryInputData repositoryInput =
        UpdateStatusRepositoryInputData(input.wordId, input.status, dateTime);
    repository.updateStatus(repositoryInput);
  }
}
