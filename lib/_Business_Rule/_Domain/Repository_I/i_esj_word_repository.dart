import 'package:my_dic/_Business_Rule/Usecase/update_status/update_status_repository_input_data.dart';
import 'package:my_dic/_Business_Rule/_Domain/Entities/word.dart';

abstract class IEsjWordRepository {
  Future<List<Word>> getWordsByWord(String word);
  void updateStatus(UpdateStatusRepositoryInputData input);
}
