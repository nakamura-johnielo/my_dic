import 'package:my_dic/_Business_Rule/_Domain/Entities/word.dart';

abstract class IEsjWordRepository {
  Future<List<Word>> getWordsByWord(String word);
}
