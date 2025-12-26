import 'package:my_dic/features/quiz/data/repository_impl/drift_es_en_conjugacions_repository.dart';
import 'package:my_dic/features/quiz/domain/usecase/fetch_english_conj.dart/i_fetch_english_conj_usecase.dart';
import 'package:my_dic/core/shared/utils/result.dart';
import 'package:my_dic/core/shared/errors/infrastructure_errors.dart';

class FetchEnglishConjInteractor implements IFetchEnglishConjUseCase{
  final DriftEsEnConjugacionRepository _driftEsEnConjugacionRepository;

  FetchEnglishConjInteractor(this._driftEsEnConjugacionRepository) ;
  
  @override
  Future<Result<Map<String, String>>> execute(int wordId) async {
    try {
      final englishConj =
          await _driftEsEnConjugacionRepository.getEnglishConjById(wordId);
      print("!!!!!!!!!!!!!!!!!!!!!!!!!englishConj in QuizController");
      print(englishConj);
      return Result.success(englishConj);
    } catch (e, stackTrace) {
      return Result.failure(DatabaseError(
        message: '英語活用形の取得に失敗しました',
        originalError: e,
        stackTrace: stackTrace,
      ));
    }
  }


}