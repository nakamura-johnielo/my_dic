import 'package:my_dic/core/domain/entity/jpn_esp/jpn_esp_word.dart';
import 'package:my_dic/core/domain/i_repository/i_jpn_esp_word_repository.dart';
import 'package:my_dic/core/infrastructure/datasource/jpn_esp/i_jpn_esp_word_data_source.dart';
import 'package:my_dic/core/infrastructure/datasource/jpn_esp/i_jpn_esp_dictionary_data_source.dart';
import 'package:my_dic/core/shared/consts/ui/ui.dart';
import 'package:my_dic/core/shared/utils/result.dart';
import 'package:my_dic/core/shared/errors/infrastructure_errors.dart';
import 'package:my_dic/core/infrastructure/repositories/converters/jpn_esp_word_converter.dart';

class JpnEspWordRepository implements IJpnEspWordRepository {
  final IJpnEspWordLocalDataSource _wordDataSource;
  final IJpnEspDictionaryLocalDataSource _dictionaryDataSource;
  JpnEspWordRepository(this._wordDataSource, this._dictionaryDataSource);

  @override
  Future<Result<List<JpnEspWord>>> getWordsByWord(
      String word, int size, int currentPage) async {
    try {
      final tableDataList =
          await _wordDataSource.getWordsByWord(word, size, currentPage);
      final entities = JpnEspWordConverter.toEntityList(tableDataList);
      return Result.success(entities);
    } catch (e, stackTrace) {
      return Result.failure(DatabaseError(
        message: '和西単語の検索に失敗しました',
        originalError: e,
        stackTrace: stackTrace,
      ));
    }
  }

  @override
  Future<Result<Map<int, int>>> getRankingNosByWordIds(
      List<int> wordIds) async {
    return Result.success(<int, int>{});
  }

  @override
  Future<Result<Map<int, String>>> getSimpleMeaningsByWordIds(
      List<int> wordIds) async {
    try {
      if (wordIds.isEmpty) return Result.success({});

      final dicHtmls = await _dictionaryDataSource.getContentsByWordIds(wordIds);

      final res = <int, String>{};


      // fill from dictionary
      dicHtmls.forEach((wordId, html) {
        final converted = _convert1line(html);
        if (converted.isEmpty) return;
        res[wordId] = converted;
      });

      return Result.success(res);
    } catch (e, s) {
      return Result.failure(DatabaseError(
        message: '簡単な意味の取得に失敗しました',
        originalError: e,
        stackTrace: s,
      ));
    }
  }


  @override
  Future<Result<Map<int, int>>> getStarCountsByWordIds(
      List<int> wordIds) async {
    return Result.success(<int, int>{});
  }

    //======local method=================================================================
  String _convert1line(String text) {
    //TODO きれいに1行にする
// 正規表現で <p data-orgtag="meaning" ...>...</p> を抽出
    final pattern =
        RegExp(r'<p data-orgtag="meaning"[^>]*>(.*?)<\/p>', dotAll: true);
    final matches = pattern.allMatches(text);
    String meanings = "";
    for (final m in matches) {
      String text = m.group(1)!;
      // さらにタグを除去（bタグなど）
      text = text.replaceAll(RegExp(r'<[^>]+>'), '');
      meanings += "$text  ";
      if (meanings.length > UIConsts.oneLineMeaningMaxLength) {
        meanings = meanings.substring(0, UIConsts.oneLineMeaningMaxLength);
        break;
      }
    }

    return meanings; // 例: ['[女] ［複～es, ～s］', '1 スペイン語字母の第1字；a の名称．', '2 〖音楽〗']
  }
}
