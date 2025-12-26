import 'package:my_dic/core/shared/utils/result.dart';
import 'package:my_dic/features/my_word/domain/usecase/load_my_word/load_my_word_repository_input_data.dart';
import 'package:my_dic/features/my_word/domain/usecase/my_word/create/register_my_word/register_my_word_repository_input_data.dart';
import 'package:my_dic/features/my_word/domain/usecase/my_word/delete/delete_my_word/delete_my_word_repository_input_data.dart';
import 'package:my_dic/features/my_word/domain/usecase/my_word/update/update_my_word/update_my_word_repository_input_data.dart';
import 'package:my_dic/features/my_word/domain/usecase/update_my_word_status/update_my_word_status_repository_input_data.dart';
import 'package:my_dic/features/my_word/domain/entity/my_word.dart';

abstract class IMyWordRepository {
  Future<Result<MyWord>> getById(int id);
  Future<Result<List<MyWord>>> getFilteredByPage(
      LoadMyWordRepositoryInputData input);

  Future<Result<void>> updateStatus(UpdateMyWordStatusRepositoryInputData input);
  Future<Result<int>> registerWord(RegisterMyWordRepositoryInputData input);
  Future<Result<void>> updateWord(UpdateMyWordRepositoryInputData input);
  Future<Result<void>> deleteWord(DeleteMyWordRepositoryInputData input);
}
 