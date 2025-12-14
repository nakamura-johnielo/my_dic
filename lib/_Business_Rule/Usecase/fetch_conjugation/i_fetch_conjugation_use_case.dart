import 'package:my_dic/_Business_Rule/Usecase/fetch_conjugation/fetch_conjugation_input_data.dart';
import 'package:my_dic/core/domain/entity/verb/conjugacion/conjugacions.dart';

abstract class IFetchConjugationUseCase {
  Future<void> execute(FetchConjugationInputData input);
  Future<Conjugacions?> executeReturn(FetchConjugationInputData input);
}
