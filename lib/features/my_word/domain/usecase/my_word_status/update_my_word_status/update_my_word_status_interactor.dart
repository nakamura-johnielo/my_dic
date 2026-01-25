import 'package:my_dic/core/shared/enums/feature_tag.dart';
import 'package:my_dic/core/shared/errors/infrastructure_errors.dart';
import 'package:my_dic/core/shared/utils/result.dart';
import 'package:my_dic/features/my_word/domain/usecase/my_word_status/update_my_word_status/update_my_word_status_input_data.dart';
import 'package:my_dic/features/my_word/domain/usecase/my_word_status/update_my_word_status/i_update_my_word_status_use_case.dart';
import 'package:my_dic/features/my_word/domain/usecase/my_word_status/update_my_word_status/update_my_word_status_output_data.dart';
import 'package:my_dic/features/my_word/domain/usecase/my_word_status/update_my_word_status/update_my_word_status_repository_input_data.dart';
import 'package:my_dic/features/my_word/domain/i_repository/i_my_word_status_repository.dart';
import 'package:my_dic/core/shared/utils/date_handler.dart';

class UpdateMyWordStatusInteractor implements IUpdateMyWordStatusUseCase {
  final IMyWordStatusRepository _myWordStatusRepository;

  UpdateMyWordStatusInteractor(this._myWordStatusRepository);

  @override
  Future<Result<void>> execute(UpdateMyWordStatusInputData input) async {
    try {
      final dateTime = DateTime.now().toUtc();
      UpdateMyWordStatusRepositoryInputData repositoryInput =
          UpdateMyWordStatusRepositoryInputData(input.wordId, input.isLearned,
              input.isBookmarked, input.hasNote, dateTime, input.userId);

      await _myWordStatusRepository.updateStatus(repositoryInput);

      // UpdateMyWordStatusOutputData output = UpdateMyWordStatusOutputData(
      //   index: input.index,
      //   wordId: input.wordId,
      //   isBookmarked: input.status.contains(FeatureTag.isBookmarked),
      //   isLearned: input.status.contains(FeatureTag.isLearned),
      //   hasNote: input.status.contains(FeatureTag.hasNote),
      // );
      // _updateMyWordStatusPresenterImpl.execute(output);

      return const Result.success(null);
    } catch (e, stackTrace) {
      return Result.failure(DatabaseError(
        message: 'ステータス更新に失敗しました',
        originalError: e,
        stackTrace: stackTrace,
      ));
    }
  }
}
