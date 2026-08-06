import 'package:my_dic/app/session/current_session.dart';
import 'package:my_dic/core/shared/utils/logger.dart';
import 'package:my_dic/core/shared/utils/result.dart';
import 'package:my_dic/features/esp_jpn_word_status/domain/i_word_status_repository.dart';
import 'package:my_dic/features/esp_jpn_word_status/domain/usecase/update_status/update_status_input_data.dart';
import 'package:my_dic/features/esp_jpn_word_status/domain/usecase/update_status/i_update_status_use_case.dart';
import 'package:my_dic/features/esp_jpn_word_status/domain/usecase/update_status/update_status_repository_input_data.dart';

class UpdateStatusInteractor implements IUpdateStatusUseCase {
  final IWordStatusRepository _wordStatusRepository;
  final CurrentSession _currentSession;

  UpdateStatusInteractor(this._wordStatusRepository, this._currentSession);

  @override
  Future<Result<void>> execute(UpdateStatusInputData input) async {
    if (!input.hasChanges) {
      return const Result.success(null);
    }

    final dateTime = DateTime.now().toUtc();
    final accountId = _currentSession.accountIdOrNull;

    // ローカルの更新を先に実行
    final localResult = await _wordStatusRepository.updateLocalWordStatus(
      UpdateStatusRepositoryInputData(
        wordId: input.wordId,
        isLearned: input.isLearned,
        isBookmarked: input.isBookmarked,
        hasNote: input.hasNote,
      ),
      dateTime,
      accountId: accountId,
    );

    // ローカル更新が失敗した場合は即座にエラーを返す
    if (localResult.isFailure) {
      return Result.failure(localResult.errorOrNull!);
    }
    final updatedStatus = localResult.dataOrNull!;

    // ログインユーザーの場合のみリモート更新を実行
    if (accountId != null) {
      final remoteResult = await _wordStatusRepository.updateRemoteWordStatus(
          updatedStatus, accountId, dateTime);

      // リモート更新が失敗してもローカルは更新済みなのでログのみ
      if (remoteResult.isFailure) {
        AppLogger.print(
            'Remote status update failed: ${remoteResult.errorOrNull?.message}');
        // リモート失敗は警告として扱い、成功を返す（ローカルは更新済み）
        // 必要に応じて後で同期可能
      }
    }

    return const Result.success(null);
  }
}
