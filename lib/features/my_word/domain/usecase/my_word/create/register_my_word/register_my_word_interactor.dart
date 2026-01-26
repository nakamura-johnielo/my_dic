import 'package:my_dic/core/shared/errors/domain_errors.dart';
import 'package:my_dic/core/shared/utils/result.dart';
import 'package:my_dic/features/auth/domain/I_repository/i_auth_repository.dart';
import 'package:my_dic/features/my_word/domain/usecase/my_word/create/register_my_word/register_my_word_input_data.dart';
import 'package:my_dic/features/my_word/domain/usecase/my_word/create/register_my_word/i_register_my_word_use_case.dart';
import 'package:my_dic/features/my_word/domain/usecase/my_word/create/register_my_word/register_my_word_repository_input_data.dart';
import 'package:my_dic/features/my_word/domain/i_repository/i_my_word_repository.dart';
import 'package:my_dic/core/shared/utils/date_handler.dart';

class RegisterMyWordInteractor implements IRegisterMyWordUseCase {
  final IMyWordRepository _driftMyWordRepository;
  final IAuthRepository _authRepository;

  RegisterMyWordInteractor(this._driftMyWordRepository, this._authRepository);

  @override
  Future<Result<String>> execute(RegisterMyWordInputData input) async {
    // Validation
    final validationError = _validateInput(input);
    if (validationError != null) {
      return Result.failure(validationError);
    }

    DateTime dateTime = DateTime.now().toUtc();
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
    RegisterMyWordRepositoryInputData repositoryInput =
        RegisterMyWordRepositoryInputData(input.headword.trim(),
            input.description.trim(), dateTime, accountId);

    return await _driftMyWordRepository.registerWord(repositoryInput);
  }

  ValidationError? _validateInput(RegisterMyWordInputData input) {
    final errors = <String, List<String>>{};

    if (input.headword.trim().isEmpty) {
      errors['headword'] = ['単語を入力してください'];
    } else if (input.headword.trim().length > 100) {
      errors['headword'] = ['単語は100文字以内で入力してください'];
    }

    if (input.description.trim().length > 1000) {
      errors['description'] = ['説明は1000文字以内で入力してください'];
    }

    if (errors.isNotEmpty) {
      return ValidationError(
        message: '入力内容に誤りがあります',
        fieldErrors: errors,
      );
    }

    return null;
  }
}
