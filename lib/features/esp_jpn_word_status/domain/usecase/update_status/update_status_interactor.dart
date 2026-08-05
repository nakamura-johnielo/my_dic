import 'package:my_dic/core/shared/utils/logger.dart';
import 'package:my_dic/core/shared/utils/result.dart';
import 'package:my_dic/features/auth/domain/I_repository/i_auth_repository.dart';
import 'package:my_dic/features/esp_jpn_word_status/domain/esp_word_status.dart';
import 'package:my_dic/features/esp_jpn_word_status/domain/i_word_status_repository.dart';
import 'package:my_dic/features/esp_jpn_word_status/domain/usecase/update_status/update_status_input_data.dart';
import 'package:my_dic/features/esp_jpn_word_status/domain/usecase/update_status/i_update_status_use_case.dart';

class UpdateStatusInteractor implements IUpdateStatusUseCase {
  final IWordStatusRepository _wordStatusRepository;
  final IAuthRepository _authRepository;

  UpdateStatusInteractor(this._wordStatusRepository, this._authRepository);

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
    AppLogger.print(
        "status:isBookmarked ${converterIntFromBool(input.isBookmarked)}");
    AppLogger.print(
        "status:isLearned ${converterIntFromBool(input.isLearned)}");

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

    //TODO authjudge
    String? accountId;
    try {
      final authResult = await _authRepository.getCurrentAuth();
      authResult.when(
        success: (auth) {
          if (auth.isAuthenticated && auth.accountId.isNotEmpty) {
            accountId = auth.accountId;
          }
        },
        failure: (error) => AppLogger.print(
          'Auth lookup failed during EspJpn status update: ${error.message}',
        ),
      );
    } catch (error) {
      AppLogger.print(
        'Unexpected auth lookup failure during EspJpn status update: $error',
      );
    }

    if (accountId != null) {
      WordStatus repoInput = WordStatus(
        wordId: input.wordId,
        isBookmarked: input.isBookmarked ?? false,
        isLearned: input.isLearned ?? false,
        hasNote: input.hasNote ?? false,
        editAt: dateTime,
      );
      final res = await _wordStatusRepository.getWordStatusById(input.wordId);
      if (res.isFailure) {
        return Result.failure(res.errorOrNull!);
      }
      final existing = res.dataOrNull;
      if (existing != null) {
        repoInput = repoInput.copyWith(
          isBookmarked: existing.isBookmarked,
          isLearned: existing.isLearned,
        );
      }

      //TODO authenticated追加
      final remoteResult = await _wordStatusRepository.updateRemoteWordStatus(
          repoInput, accountId!, dateTime);

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
