import 'package:my_dic/_Business_Rule/Usecase/load_my_word/load_my_word_repository_input_data.dart';
import 'package:my_dic/_Business_Rule/_Domain/Entities/my_word.dart';

abstract class ILoadMyWordRepository {
  Future<String> getById(int id);
  Future<List<MyWord>> getFilteredByPage(LoadMyWordRepositoryInputData input);
}
