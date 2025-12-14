import 'dart:developer';

import 'package:my_dic/Constants/Enums/feature_tag.dart';
import 'package:my_dic/_Business_Rule/Usecase/my_word/create/register_my_word/register_my_word_input_data.dart';
import 'package:my_dic/_Business_Rule/Usecase/my_word/create/register_my_word/register_my_word_repository_input_data.dart';
import 'package:my_dic/_Business_Rule/Usecase/my_word/delete/delete_my_word/delete_my_word_repository_input_data.dart';
import 'package:my_dic/_Business_Rule/Usecase/my_word/update/update_my_word/update_my_word_repository_input_data.dart';
import 'package:my_dic/_Business_Rule/Usecase/update_my_word_status/update_my_word_status_repository_input_data.dart';
import 'package:my_dic/_Business_Rule/_Domain/Entities/my_word.dart';
import 'package:my_dic/_Business_Rule/_Domain/Repository_I/i_my_word_repository.dart';
import 'package:my_dic/_Business_Rule/Usecase/load_my_word/load_my_word_repository_input_data.dart';
import 'package:my_dic/_Framework_Driver/local/drift/DAO/my_word_dao.dart';
import 'package:my_dic/_Framework_Driver/local/drift/DAO/my_word_status_dao.dart';
import 'package:my_dic/core/infrastructure/database/database_provider.dart'
    as db;

class DriftMyWordRepository implements IMyWordRepository {
  final MyWordDao _myWordDao;
  final MyWordStatusDao _wordStatusDao;

  DriftMyWordRepository(this._myWordDao, this._wordStatusDao);

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

  @override
  Future<void> updateStatus(UpdateMyWordStatusRepositoryInputData input) async {
    log("updatestatusrepo");
    db.MyWordStatusData data = db.MyWordStatusData(
      myWordId: input.wordId,
      isLearned: input.status.contains(FeatureTag.isLearned) ? 1 : 0,
      isBookmarked: input.status.contains(FeatureTag.isBookmarked) ? 1 : 0,
      hasNote: input.status.contains(FeatureTag.hasNote) ? 1 : 0,
      editAt: input.editAt,
    );

    if (await _wordStatusDao.exist(input.wordId)) {
      _wordStatusDao.updateStatus(data);
      return;
    }
    _wordStatusDao.insertStatus(data);
  }

  @override
  Future<int> registerWord(RegisterMyWordRepositoryInputData input) async {
    return await _myWordDao.insertMyWord(
        input.headword, input.description, input.dateTime);
  }

  @override
  Future<bool> deleteWord(DeleteMyWordRepositoryInputData input) async {
    try {
      await _myWordDao.deleteMyword(input.id, input.dateTime);
      return true;
    } catch (e) {
      return false;
    }
  }

  @override
  Future<bool> updateWord(UpdateMyWordRepositoryInputData input) async {
    try {
      await _myWordDao.updateMyWord(
          input.myWordId, input.headword, input.description, input.editAt);
      return true;
    } catch (e) {
      return false;
    }
  }
}
