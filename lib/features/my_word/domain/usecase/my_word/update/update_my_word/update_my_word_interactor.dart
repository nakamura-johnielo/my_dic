
import 'package:my_dic/core/shared/errors/domain_errors.dart';
import 'package:my_dic/core/shared/utils/result.dart';
import 'package:my_dic/features/my_word/domain/usecase/my_word/update/update_my_word/update_my_word_input_data.dart';
import 'package:my_dic/features/my_word/domain/usecase/my_word/update/update_my_word/i_update_my_word_use_case.dart';
import 'package:my_dic/features/my_word/domain/usecase/my_word/update/update_my_word/update_my_word_repository_input_data.dart';
import 'package:my_dic/features/my_word/domain/i_repository/i_my_word_repository.dart';
import 'package:my_dic/core/shared/utils/date_handler.dart';

class UpdateMyWordInteractor implements IUpdateMyWordUseCase {
  final IMyWordRepository _driftMyWordRepository;

  UpdateMyWordInteractor(this._driftMyWordRepository);

  @override
  Future<Result<void>> execute(UpdateMyWordInputData input) async {
    // Validation
    final validationError = _validateInput(input);
    if (validationError != null) {
      return Result.failure(validationError);
    }

    final dateTime = DateTime.now().toUtc();

    UpdateMyWordRepositoryInputData repositoryInput =
        UpdateMyWordRepositoryInputData(
            input.myWordId, input.headword.trim(), input.description.trim(), dateTime,input.userId);

    return await _driftMyWordRepository.updateWord(repositoryInput);
  }

  ValidationError? _validateInput(UpdateMyWordInputData input) {
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
