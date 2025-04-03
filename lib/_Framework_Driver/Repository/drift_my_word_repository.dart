import 'package:my_dic/_Business_Rule/_Domain/Entities/my_word.dart';
import 'package:my_dic/_Business_Rule/_Domain/Repository_I/i_load_my_word_repository.dart';
import 'package:my_dic/_Business_Rule/Usecase/load_my_word/load_my_word_repository_input_data.dart';
import 'package:my_dic/_Framework_Driver/Database/drift/DAO/my_word_dao.dart';

class DriftMyWordRepository implements ILoadMyWordRepository {
  final MyWordDao _myWordDao;

  DriftMyWordRepository(this._myWordDao);

  @override
  Future<String> getById(int id) async {
    //res = await _myWordDao.getById(id);
    return "";
  }

  @override
  Future<List<MyWord>> getFilteredByPage(
      LoadMyWordRepositoryInputData input) async {
    final res =
        await _myWordDao.getFilteredMyWordByPage(input.size, input.offset);
    if (res == null) {
      List<MyWord> l = [];
      return l;
    }

    return res.map((data) {
      return MyWord(
          isBookmarked: false,
          isLearned: false,
          contents: data.contents ?? "",
          word: data.word,
          wordId: data.myWordId);
    }).toList();
  }
}
