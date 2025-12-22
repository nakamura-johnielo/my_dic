import 'package:my_dic/core/domain/entity/verb/new_conjugacions.dart';
import 'package:my_dic/core/domain/entity/verb/conjugacion/conjugacions.dart';
import 'package:my_dic/core/domain/i_repository/i_conjugation_repository.dart';
import 'package:my_dic/core/domain/usecase/new_fetch_conjugation/fetch_conjugation_input_data.dart';
import 'package:my_dic/core/domain/usecase/new_fetch_conjugation/i_fetch_conjugation_use_case.dart';

class FetchEspConjugationInteractor implements IFetchEspConjugationUseCase {
  final IConjugacionsRepository _conjugacionRepository;

  FetchEspConjugationInteractor(this._conjugacionRepository);



  @override
  Future<EspConjugacions?> execute(FetchConjugationInputData input) async {
    //FetchConjugationRepositoryInputData repositoryInput=FetchConjugationRepositoryInputData();
    EspConjugacions? data =
        await _conjugacionRepository.getConjugacionByWordIdNEW(input.wordId);
    return data;
  }
}
