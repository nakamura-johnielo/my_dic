import 'package:my_dic/app/session/current_session.dart';
import 'package:my_dic/core/shared/consts/account_scope.dart';
import 'package:my_dic/core/shared/errors/domain_errors.dart';
import 'package:my_dic/core/shared/utils/result.dart';
import 'package:my_dic/features/my_word/domain/usecase/my_word/load_my_word/load_my_word_input_data.dart';
import 'package:my_dic/features/my_word/domain/usecase/my_word/load_my_word/i_load_my_word_use_case.dart';
import 'package:my_dic/features/my_word/domain/usecase/my_word/load_my_word/load_my_word_repository_input_data.dart';
import 'package:my_dic/features/my_word/domain/entity/my_word.dart';
import 'package:my_dic/features/my_word/domain/i_repository/i_my_word_repository.dart';

class LoadMyWordInteractor implements ILoadMyWordUseCase {
  final IMyWordRepository _driftLoadMyWordRepository;
  final CurrentSession _currentSession;

  LoadMyWordInteractor(this._driftLoadMyWordRepository, this._currentSession);

  String get _scope => _currentSession.accountIdOrNull ?? guestAccountScope;

  @override //TODO 使っていない
  Future<Result<List<MyWord>>> execute(LoadMyWordInputData input) async {
    // Validation
    final validationError = _validateInput(input);
    if (validationError != null) {
      return Result.failure(validationError);
    }

    int offset = input.requiredPage * input.size;
    LoadMyWordRepositoryInputData repositoryInput =
        LoadMyWordRepositoryInputData(input.size, offset);

    return await _driftLoadMyWordRepository.getFilteredByPage(repositoryInput,
        accountId: _scope);
  }

  ValidationError? _validateInput(LoadMyWordInputData input) {
    if (input.requiredPage < 0) {
      return ValidationError(
        message: 'ページ番号は0以上である必要があります',
      );
    }

    if (input.size <= 0) {
      return ValidationError(
        message: 'ページサイズは1以上である必要があります',
      );
    }

    return null;
  }

  @override
  Future<Result<List<String>>> executeIds(LoadMyWordInputData input) async {
    // Validation
    final validationError = _validateInput(input);
    if (validationError != null) {
      return Result.failure(validationError);
    }

    int offset = input.requiredPage * input.size;
    LoadMyWordRepositoryInputData repositoryInput =
        LoadMyWordRepositoryInputData(input.size, offset);

    return await _driftLoadMyWordRepository
        .getIdsFilteredByPage(repositoryInput, accountId: _scope);
  }
}
