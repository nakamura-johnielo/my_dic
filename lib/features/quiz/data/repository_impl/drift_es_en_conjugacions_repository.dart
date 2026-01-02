import 'package:my_dic/core/shared/enums/conjugacion/mood_tense.dart';
import 'package:my_dic/core/shared/errors/infrastructure_errors.dart';
import 'package:my_dic/core/shared/utils/result.dart';
import 'package:my_dic/features/quiz/data/data_source/local/i_es_en_conjugacion_local_data_source.dart';
import 'package:my_dic/features/quiz/domain/usecase/fetch_english_conj.dart/i_fetch_english_conj_repository.dart';

class EsEnConjugacionRepository implements IEsEnConjugacionRepository{
  final IEsEnConjugacionLocalDataSource _dataSource;

  EsEnConjugacionRepository(this._dataSource);

  @override
  Future<Result<Map<String, String>>> getEnglishConjById(int id) async {
    try {
      final data = await _dataSource.getEnglishConjById(id);
      final result = {
        EnglishMoodTense.participlePresent.toString(): data?.presentP ?? "V-ing",
        EnglishMoodTense.participlePast.toString(): data?.pastP ?? "V-en",
        EnglishMoodTense.indicativePresent.toString(): data?.english ?? "V",
        EnglishMoodTense.indicativePresent3rd.toString(): data?.present3rd ?? "Vs",
        EnglishMoodTense.indicativePast.toString(): data?.past ?? "V-ed",
      };
      return Result.success(result);
    } catch (e, stackTrace) {
      return Result.failure(DatabaseError(
        message: '英語活用形の取得に失敗しました',
        originalError: e,
        stackTrace: stackTrace,
      ));
    }
  }
}
