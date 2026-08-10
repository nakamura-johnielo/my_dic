import 'package:my_dic/core/shared/utils/result.dart';
import 'package:my_dic/features/my_word/internal/domain/model/my_word/load_my_word_repository_input_data.dart';
import 'package:my_dic/features/my_word/internal/domain/model/my_word/register_my_word_repository_input_data.dart';
import 'package:my_dic/features/my_word/internal/domain/model/my_word/delete_my_word_repository_input_data.dart';
import 'package:my_dic/features/my_word/internal/domain/model/my_word/update_my_word_repository_input_data.dart';
import 'package:my_dic/features/my_word/internal/domain/entity/my_word.dart';

abstract class IMyWordRepository {
  // normal methods
  Future<Result<MyWord>> getById(String id, {required String accountId});
  Future<Result<List<MyWord>>> getFilteredByPage(
      LoadMyWordRepositoryInputData input,
      {required String accountId}); //TODO: 使用状況を確認する
  Future<Result<List<String>>> getIdsFilteredByPage(
      LoadMyWordRepositoryInputData input,
      {required String accountId});

  Future<Result<String>> registerWord(RegisterMyWordRepositoryInputData input);
  Future<Result<void>> updateWord(UpdateMyWordRepositoryInputData input);
  Future<Result<void>> deleteWord(DeleteMyWordRepositoryInputData input);

  Stream<MyWord> watchMyWord(String id, {required String accountId});
}
