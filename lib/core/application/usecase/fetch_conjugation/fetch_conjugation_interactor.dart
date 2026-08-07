import 'package:my_dic/core/application/usecase/fetch_conjugation/fetch_conjugation_input_data.dart';
import 'package:my_dic/core/application/usecase/fetch_conjugation/i_fetch_conjugation_use_case.dart';
import 'package:my_dic/core/domain/entity/verb/conjugacions.dart';
import 'package:my_dic/core/domain/i_repository/i_conjugation_repository.dart';
import 'package:my_dic/core/shared/utils/result.dart';

class FetchEspConjugationInteractor implements IFetchEspConjugationUseCase {
  final IConjugacionsRepository _repository;

  FetchEspConjugationInteractor(this._repository);

  @override
  Future<Result<EspConjugacions?>> execute(FetchConjugationInputData input) =>
      _repository.getConjugacionByWordId(input.wordId);
}
