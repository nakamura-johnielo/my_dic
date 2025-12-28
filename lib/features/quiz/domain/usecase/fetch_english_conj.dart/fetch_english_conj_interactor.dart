import 'package:my_dic/features/quiz/data/repository_impl/drift_es_en_conjugacions_repository.dart';
import 'package:my_dic/features/quiz/domain/usecase/fetch_english_conj.dart/i_fetch_english_conj_usecase.dart';
import 'package:my_dic/core/shared/utils/result.dart';

class FetchEnglishConjInteractor implements IFetchEnglishConjUseCase{
  final DriftEsEnConjugacionRepository _driftEsEnConjugacionRepository;

  FetchEnglishConjInteractor(this._driftEsEnConjugacionRepository) ;
  
  @override
  Future<Result<Map<String, String>>> execute(int wordId) async {
    final result =
        await _driftEsEnConjugacionRepository.getEnglishConjById(wordId);
    print("!!!!!!!!!!!!!!!!!!!!!!!!!englishConj in QuizController");
    print(result);
    return result;
  }


}