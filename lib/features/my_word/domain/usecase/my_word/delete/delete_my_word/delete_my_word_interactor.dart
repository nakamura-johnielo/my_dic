import 'package:my_dic/core/shared/utils/result.dart';
import 'package:my_dic/features/auth/domain/I_repository/i_auth_repository.dart';
import 'package:my_dic/features/my_word/domain/usecase/my_word/delete/delete_my_word/delete_my_word_input_data.dart';
import 'package:my_dic/features/my_word/domain/usecase/my_word/delete/delete_my_word/i_delete_my_word_use_case.dart';
import 'package:my_dic/features/my_word/domain/usecase/my_word/delete/delete_my_word/delete_my_word_repository_input_data.dart';
import 'package:my_dic/features/my_word/domain/i_repository/i_my_word_repository.dart';
import 'package:my_dic/core/shared/utils/date_handler.dart';

class DeleteMyWordInteractor implements IDeleteMyWordUseCase {
  final IMyWordRepository _driftMyWordRepository;
  final IAuthRepository _authRepository;

  DeleteMyWordInteractor(this._driftMyWordRepository, this._authRepository);

  @override
  Future<Result<void>> execute(DeleteMyWordInputData input) async {
    String dateTime = getNowUTCDateHour();
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
        failure: (_) {},
      );
    } catch (_) {
      // ignore and treat as unauthenticated
    }

    DeleteMyWordRepositoryInputData repositoryInput =
        DeleteMyWordRepositoryInputData(input.id, dateTime, accountId);

    return await _driftMyWordRepository.deleteWord(repositoryInput);
  }
}
