import 'package:my_dic/features/my_word/domain/usecase/load_my_word/load_my_word_repository_input_data.dart';
import 'package:my_dic/features/my_word/domain/usecase/my_word/create/register_my_word/register_my_word_repository_input_data.dart';
import 'package:my_dic/features/my_word/domain/usecase/my_word/delete/delete_my_word/delete_my_word_repository_input_data.dart';
import 'package:my_dic/features/my_word/domain/usecase/my_word/update/update_my_word/update_my_word_repository_input_data.dart';
import 'package:my_dic/features/my_word/domain/usecase/update_my_word_status/update_my_word_status_repository_input_data.dart';
import 'package:my_dic/features/my_word/domain/entity/my_word.dart';

abstract class IMyWordRepository {
  Future<String> getById(int id);
  Future<List<MyWord>> getFilteredByPage(LoadMyWordRepositoryInputData input);

  Future<void> updateStatus(UpdateMyWordStatusRepositoryInputData input);
  Future<int> registerWord(RegisterMyWordRepositoryInputData input);
  Future<bool> updateWord(UpdateMyWordRepositoryInputData input);
  Future<bool> deleteWord(DeleteMyWordRepositoryInputData input);
}
