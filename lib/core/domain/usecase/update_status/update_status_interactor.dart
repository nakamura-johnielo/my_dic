import 'dart:developer';

import 'package:my_dic/core/shared/enums/feature_tag.dart';
import 'package:my_dic/core/shared/utils/result.dart';
import 'package:my_dic/core/domain/entity/word/esp_word_status.dart';
import 'package:my_dic/core/domain/i_repository/i_word_status_repository.dart';
import 'package:my_dic/core/domain/usecase/update_status/update_status_input_data.dart';
import 'package:my_dic/core/domain/usecase/update_status/i_update_status_use_case.dart';


class UpdateStatusInteractor implements IUpdateStatusUseCase {
  final IWordStatusRepository _wordStatusRepository;

  UpdateStatusInteractor(
      this._wordStatusRepository);
  @override
  Future<Result<void>> execute(UpdateStatusInputData input) async {
    final dateTime = DateTime.now().toUtc();

    WordStatus repoInput = WordStatus(
      wordId: input.wordId,
      isBookmarked: input.status.contains(FeatureTag.isBookmarked),
      isLearned: input.status.contains(FeatureTag.isLearned),
      hasNote: input.status.contains(FeatureTag.hasNote),
      editAt: dateTime,
    );
    
    // ローカルの更新を先に実行
    final localResult = await _wordStatusRepository.updateLocalWordStatus(
        repoInput, dateTime);
    
    // ローカル更新が失敗した場合は即座にエラーを返す
    if (localResult.isFailure) {
      return localResult;
    }

    // ログインユーザーの場合のみリモート更新を実行
    if (input.accountId != null) {
      final remoteResult = await _wordStatusRepository.updateRemoteWordStatus(
          repoInput, input.accountId!, dateTime);
      
      // リモート更新が失敗してもローカルは更新済みなのでログのみ
      if (remoteResult.isFailure) {
        log('Remote status update failed: ${remoteResult.errorOrNull?.message}');
        // リモート失敗は警告として扱い、成功を返す（ローカルは更新済み）
        // 必要に応じて後で同期可能
      }
    }

    return const Result.success(null);
  }
}
