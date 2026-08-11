import 'package:my_dic/core/shared/utils/result.dart';
import 'package:my_dic/features/quiz/internal/game/application/usecase/i_fetch_english_conj_usecase.dart';
import 'package:my_dic/features/quiz/internal/game/domain/i_repository/i_es_en_conjugacion_repository.dart';

class FetchEnglishConjInteractor implements IFetchEnglishConjUseCase {
  final IEsEnConjugacionRepository _repository;

  FetchEnglishConjInteractor(this._repository);

  @override
  Future<Result<Map<String, String>>> execute(int wordId) =>
      _repository.getEnglishConjById(wordId);
}
