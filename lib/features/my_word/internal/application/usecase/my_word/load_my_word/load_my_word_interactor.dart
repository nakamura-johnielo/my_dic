import 'package:my_dic/core/shared/errors/domain_errors.dart';
import 'package:my_dic/core/shared/utils/result.dart';
import 'package:my_dic/features/my_word/internal/application/usecase/my_word/load_my_word/load_my_word_input_data.dart';
import 'package:my_dic/features/my_word/internal/application/usecase/my_word/load_my_word/i_load_my_word_use_case.dart';
import 'package:my_dic/features/my_word/internal/domain/inputData/my_word/load_my_word_repository_input_data.dart';
import 'package:my_dic/features/my_word/internal/domain/entity/my_word.dart';
import 'package:my_dic/features/my_word/internal/domain/i_repository/i_my_word_repository.dart';

class LoadMyWordInteractor implements ILoadMyWordUseCase {
  final IMyWordRepository _myWordRepository;
  LoadMyWordInteractor(this._myWordRepository);

  @override
  Future<Result<List<MyWord>>> execute(LoadMyWordInputData input) async {
    final validationError = _validateInput(input);
    if (validationError != null) {
      return Result.failure(validationError);
    }

    final offset = input.requiredPage * input.size;
    final repositoryInput = LoadMyWordRepositoryInputData(input.size, offset);

    return _myWordRepository.getFilteredByPage(
      repositoryInput,
      accountId: input.accountScope,
    );
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
    final validationError = _validateInput(input);
    if (validationError != null) {
      return Result.failure(validationError);
    }

    final offset = input.requiredPage * input.size;
    final repositoryInput = LoadMyWordRepositoryInputData(input.size, offset);

    return _myWordRepository.getIdsFilteredByPage(
      repositoryInput,
      accountId: input.accountScope,
    );
  }
}
