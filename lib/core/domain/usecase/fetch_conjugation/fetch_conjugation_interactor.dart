import 'package:my_dic/core/domain/entity/verb/conjugacions.dart';
import 'package:my_dic/core/domain/i_repository/i_conjugation_repository.dart';
import 'package:my_dic/core/domain/usecase/fetch_conjugation/fetch_conjugation_input_data.dart';
import 'package:my_dic/core/domain/usecase/fetch_conjugation/i_fetch_conjugation_use_case.dart';
import 'package:my_dic/core/shared/utils/result.dart';
import 'package:my_dic/core/shared/errors/infrastructure_errors.dart';

class FetchEspConjugationInteractor implements IFetchEspConjugationUseCase {
  final IConjugacionsRepository _conjugacionRepository;

  FetchEspConjugationInteractor(this._conjugacionRepository);



  @override
  Future<Result<EspConjugacions?>> execute(FetchConjugationInputData input) async {
    // リポジトリが既にResult<T>を返すのでそのまま返す
    return await _conjugacionRepository.getConjugacionByWordId(input.wordId);
  }
}
