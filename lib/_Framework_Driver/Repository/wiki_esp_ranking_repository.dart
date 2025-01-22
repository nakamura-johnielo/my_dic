import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:my_dic/Constants/Enums/feature_tag.dart';
import 'package:my_dic/Constants/Enums/part_of_speech.dart';
import 'package:my_dic/_Business_Rule/Usecase/add_filter/add_filter_input_data.dart';
import 'package:my_dic/_Business_Rule/Usecase/add_filter/add_filter_repository_input_data.dart';
import 'package:my_dic/_Business_Rule/Usecase/set_ranking_items/filtered_ranking_list_input_data.dart';
import 'package:my_dic/_Business_Rule/_Domain/Entities/ranking.dart';
import 'package:my_dic/_Business_Rule/_Domain/Repository_I/i_esp_ranking_repository.dart';
import 'package:my_dic/_Framework_Driver/Database/drift/DAO/ranking_dao.dart';

class WikiEspRankingRepository implements IEspRankingRepository {
  RankingDao _rankingDao;
  WikiEspRankingRepository(this._rankingDao);

  @override
  Future<List<Ranking>> getRankingList(int page, int size) async {
    log("############################################ranking dao");
    final res =
        await _rankingDao.getRankingListByPage(page = page, size = size);
    if (res == null) {
      List<Ranking> l = [];
      return l;
    }

    return res.map((d) {
      return Ranking(
          rank: d.rankingNo,
          rankedWord: (d.word == null) ? "---" : d.word!,
          lemma: (d.wordOrigin == null) ? "---" : d.wordOrigin!,
          wordId: (d.wordId == null) ? -1 : d.wordId!);
    }).toList();
  }

  @override
  Future<List<Ranking>> getRankingListByFilters(
      FilteredRankingListInputData input) async {
    final rankings = await _rankingDao.getFilteredRankingListByPage(input.page,
        input.size, input.partOfSpeechFilters, input.featureTagFilters);

    if (rankings == null || rankings.isEmpty) {
      List<Ranking> res = [];
      return res;
    }

    /* for (int i = 0; i < 20; i++) {
      log("word: ${rankings[i]}");
    } */
    return rankings.map((ranking) {
      return Ranking(
        rank: ranking.rankingNo,
        rankedWord: ranking.word ?? "",
        lemma: ranking.wordOrigin ?? "",
        wordId: ranking.wordId ?? -1,
      );
    }).toList();
  }
}
