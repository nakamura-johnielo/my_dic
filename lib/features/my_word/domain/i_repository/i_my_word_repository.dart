import 'package:my_dic/core/shared/utils/result.dart';
import 'package:my_dic/features/my_word/domain/usecase/my_word/load_my_word/load_my_word_repository_input_data.dart';
import 'package:my_dic/features/my_word/domain/usecase/my_word/create/register_my_word/register_my_word_repository_input_data.dart';
import 'package:my_dic/features/my_word/domain/usecase/my_word/delete/delete_my_word/delete_my_word_repository_input_data.dart';
import 'package:my_dic/features/my_word/domain/usecase/my_word/update/update_my_word/update_my_word_repository_input_data.dart';
import 'package:my_dic/features/my_word/domain/entity/my_word.dart';

abstract class IMyWordRepository {
  // normal methods
  Future<Result<MyWord>> getById(int id);
  Future<Result<List<MyWord>>> getFilteredByPage(
      LoadMyWordRepositoryInputData input);//TODO 使っていない
  Future<Result<List<int>>> getIdsFilteredByPage(
      LoadMyWordRepositoryInputData input);

  Future<Result<int>> registerWord(RegisterMyWordRepositoryInputData input);
  Future<Result<void>> updateWord(UpdateMyWordRepositoryInputData input);
  Future<Result<void>> deleteWord(DeleteMyWordRepositoryInputData input);

  // Remote sync methods
  Future<Result<List<MyWord>>> getRemoteMyWordsAfter(
      String userId, DateTime datetime);
  Future<Result<MyWord?>> getRemoteMyWordById(String userId, int myWordId);
  Future<Result<void>> updateRemoteMyWord(
      String userId, MyWord myWord, DateTime? now);
  Future<Result<void>> updateBatchRemoteMyWords(
      String userId, List<MyWord> myWordList);
  Future<Result<void>> deleteRemoteMyWord(String userId, int myWordId);

  // Local methods
  Future<Result<List<MyWord>>> getLocalMyWordsAfter(DateTime datetime);
  Future<Result<MyWord?>> getLocalMyWordById(int myWordId);
  Future<Result<void>> updateLocalMyWord(MyWord myWord, DateTime now);
  Future<Result<void>> createLocalMyWord(MyWord myWord);

  Stream<List<int>> watchRemoteChangedIds(String userId);
  Stream<List<int>> watchLocalChangedIds(DateTime datetime);
  Stream<MyWord> watchMyWord(int id);
}
 