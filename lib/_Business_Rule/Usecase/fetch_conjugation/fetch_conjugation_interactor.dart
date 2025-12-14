import 'package:my_dic/_Business_Rule/Usecase/fetch_conjugation/fetch_conjugation_input_data.dart';
import 'package:my_dic/_Business_Rule/Usecase/fetch_conjugation/i_fetch_conjugation_use_case.dart';
import 'package:my_dic/_Business_Rule/Usecase/fetch_conjugation/fetch_conjugation_output_data.dart';
import 'package:my_dic/_Business_Rule/Usecase/fetch_conjugation/i_fetch_conjugation_presenter.dart';
import 'package:my_dic/core/domain/entity/verb/conjugacion/conjugacions.dart';
import 'package:my_dic/core/domain/i_repository/i_conjugation_repository.dart';

class FetchConjugationInteractor implements IFetchConjugationUseCase {
  final IFetchConjugationPresenter _conjugationFragmentPresenterImpl;
  final IConjugacionsRepository _conjugacionRepository;

  FetchConjugationInteractor(
      this._conjugationFragmentPresenterImpl, this._conjugacionRepository);

  @override
  Future<void> execute(FetchConjugationInputData input) async {
    //FetchConjugationRepositoryInputData repositoryInput=FetchConjugationRepositoryInputData();
    Conjugacions? data =
        await _conjugacionRepository.getConjugacionByWordId(input.wordId);

    FetchConjugationOutputData output =
        FetchConjugationOutputData(data, input.wordId);
    _conjugationFragmentPresenterImpl.execute(output);
  }

  @override
  Future<Conjugacions?> executeReturn(FetchConjugationInputData input) async {
    //FetchConjugationRepositoryInputData repositoryInput=FetchConjugationRepositoryInputData();
    Conjugacions? data =
        await _conjugacionRepository.getConjugacionByWordId(input.wordId);
    return data;
  }
}
