
import 'package:my_dic/core/shared/utils/logger.dart';
import 'package:my_dic/core/shared/utils/result.dart';
import 'package:my_dic/features/auth/domain/I_repository/i_auth_repository.dart';
import 'package:my_dic/features/jpn_esp_word_status/domain/jpn_esp_word_status.dart';
import 'package:my_dic/features/jpn_esp_word_status/domain/i_jpn_esp_word_status_repository.dart';
import 'package:my_dic/features/jpn_esp_word_status/domain/usecase/update_jpn_esp_status/update_jpn_esp_status_input_data.dart';
import 'package:my_dic/features/jpn_esp_word_status/domain/usecase/update_jpn_esp_status/i_update_jpn_esp_status_use_case.dart';

class UpdateJpnEspStatusInteractor implements IUpdateJpnEspStatusUseCase {
  final IJpnEspWordStatusRepository _wordStatusRepository;
  final IAuthRepository _authRepository;

  UpdateJpnEspStatusInteractor(this._wordStatusRepository, this._authRepository);

  int? converterIntFromBool(bool? value) {
    if (value == null) {
      return null;
    }
    return value ? 1 : 0;
  }

  @override
  Future<Result<void>> execute(UpdateJpnEspStatusInputData input) async {
    final dateTime = DateTime.now().toUtc();

    // Update local first
    AppLogger.print("jpn_esp status:isBookmarked ${converterIntFromBool(input.isBookmarked)}");
    AppLogger.print("jpn_esp status:isLearned ${converterIntFromBool(input.isLearned)}");

    final localResult = await _wordStatusRepository.updateLocalWordStatus(
      input.wordId,
      converterIntFromBool(input.isLearned),
      converterIntFromBool(input.isBookmarked),
      converterIntFromBool(input.hasNote),
      dateTime,
    );

    // Return error immediately if local update failed
    if (localResult.isFailure) {
      return localResult;
    }

    // Update remote only for logged-in users
    String? accountId;
    try {
      final authResult = await _authRepository.getCurrentAuth();
      authResult.when(
        success: (auth) {
          if (auth.isAuthenticated && auth.accountId.isNotEmpty) {
            accountId = auth.accountId;
          }
        },
        failure: (_) {},
      );
    } catch (_) {
      // ignore and treat as unauthenticated
    }

    if (accountId != null) {
      JpnEspWordStatus repoInput = JpnEspWordStatus(
        wordId: input.wordId,
        isBookmarked: input.isBookmarked ?? false,
        isLearned: input.isLearned ?? false,
        hasNote: input.hasNote ?? false,
        editAt: dateTime,
      );
      final res = await _wordStatusRepository.getWordStatusById(input.wordId);
      res.when(
        success: (data) {
          AppLogger.print('Fetched existing jpn_esp status for wordId ${input.wordId}: $data');
          if (data == null) return;
          repoInput = repoInput.copyWith(
              isBookmarked: data.isBookmarked, isLearned: data.isLearned);
        },
        failure: (error) {
          AppLogger.print('Failed to fetch existing jpn_esp status for wordId ${input.wordId}: ${error.message}');
        },
      );

      final remoteResult = await _wordStatusRepository.updateRemoteWordStatus(
          repoInput, accountId!, dateTime);

      // Remote failure is logged but local is already updated
      if (remoteResult.isFailure) {
        AppLogger.print('Remote jpn_esp status update failed: ${remoteResult.errorOrNull?.message}');
        // Treat remote failure as warning, return success (local is updated)
        // Can sync later if needed
      }
    }

    return const Result.success(null);
  }
}
