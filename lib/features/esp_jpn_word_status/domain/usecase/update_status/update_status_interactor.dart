import 'dart:developer';

import 'package:my_dic/core/shared/enums/feature_tag.dart';
import 'package:my_dic/core/shared/utils/result.dart';
import 'package:my_dic/features/esp_jpn_word_status/domain/esp_word_status.dart';
import 'package:my_dic/features/esp_jpn_word_status/domain/i_word_status_repository.dart';
import 'package:my_dic/features/esp_jpn_word_status/domain/usecase/update_status/update_status_input_data.dart';
import 'package:my_dic/features/esp_jpn_word_status/domain/usecase/update_status/i_update_status_use_case.dart';

class UpdateStatusInteractor implements IUpdateStatusUseCase {
  final IWordStatusRepository _wordStatusRepository;

  UpdateStatusInteractor(this._wordStatusRepository);

  int? converterIntFromBool(bool? value) {
    if (value == null) {
      return null;
    }
    return value ? 1 : 0;
  }

  @override
  Future<Result<void>> execute(UpdateStatusInputData input) async {
    final dateTime = DateTime.now().toUtc();

    // ローカルの更新を先に実行
    print("status:isBookmarked ${converterIntFromBool(input.isBookmarked)}");
    print("status:isLearned ${converterIntFromBool(input.isLearned)}");

    final localResult = await _wordStatusRepository.updateLocalWordStatus(
      input.wordId,
      converterIntFromBool(input.isLearned),
      converterIntFromBool(input.isBookmarked),
      converterIntFromBool(input.hasNote),
      dateTime,
    );

    // ローカル更新が失敗した場合は即座にエラーを返す
    if (localResult.isFailure) {
      return localResult;
    }

    // ログインユーザーの場合のみリモート更新を実行
    if (input.accountId != null) {
      WordStatus repoInput = WordStatus(
        wordId: input.wordId,
        isBookmarked: input.isBookmarked ?? false,
        isLearned: input.isLearned ?? false,
        hasNote: input.hasNote ?? false,
        editAt: dateTime,
      );
      final res = await _wordStatusRepository.getWordStatusById(input.wordId);
      res.when(
        success: (data) {
          log('Fetched existing status for wordId ${input.wordId}: $data');
          if (data == null) return;
          repoInput = repoInput.copyWith(
              isBookmarked: data.isBookmarked, isLearned: data.isLearned);
        },
        failure: (error) {
          log('Failed to fetch existing status for wordId ${input.wordId}: ${error.message}');
        },
      );

      //TODO authenticated追加
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
