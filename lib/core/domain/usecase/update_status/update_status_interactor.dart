import 'package:my_dic/core/common/enums/feature_tag.dart';
import 'package:my_dic/core/domain/entity/word/esp_word_status.dart';
import 'package:my_dic/core/domain/i_repository/i_word_status_repository.dart';
import 'package:my_dic/core/domain/usecase/update_status/update_status_input_data.dart';
import 'package:my_dic/core/domain/usecase/update_status/i_update_status_use_case.dart';


class UpdateStatusInteractor implements IUpdateStatusUseCase {
  final IWordStatusRepository _wordStatusRepository;

  UpdateStatusInteractor(
      this._wordStatusRepository);
  @override
  Future<void> execute(UpdateStatusInputData input) async {
    final dateTime = DateTime.now().toUtc();

    WordStatus repoInput = WordStatus(
      wordId: input.wordId,
      isBookmarked: input.status.contains(FeatureTag.isBookmarked),
      isLearned: input.status.contains(FeatureTag.isLearned),
      hasNote: input.status.contains(FeatureTag.hasNote),
      editAt: dateTime,
    );
    await _wordStatusRepository.updateLocalWordStatus(repoInput, dateTime, input.userId);

    if (input.userId!="logout"&&input.userId!="anonymous" ){
       await _wordStatusRepository.updateRemoteWordStatus(repoInput, dateTime, input.userId);

    }

  }
}
