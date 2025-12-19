import 'package:my_dic/features/quiz/data/repository_impl/drift_es_en_conjugacions_repository.dart';
import 'package:my_dic/features/quiz/domain/usecase/fetch_english_conj.dart/i_fetch_english_conj_usecase.dart';

class FetchEnglishConjInteractor implements IFetchEnglishConjUseCase{
  final DriftEsEnConjugacionRepository _driftEsEnConjugacionRepository;

  FetchEnglishConjInteractor(this._driftEsEnConjugacionRepository) ;
  
  @override
  Future<Map<String, String>> execute(int wordId) async {
    final englishConj =
        await _driftEsEnConjugacionRepository.getEnglishConjById(wordId);
    print("!!!!!!!!!!!!!!!!!!!!!!!!!englishConj in QuizController");
    print(englishConj);
    return englishConj;
  }


}