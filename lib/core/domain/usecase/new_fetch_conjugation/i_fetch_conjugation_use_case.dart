import 'package:my_dic/core/domain/entity/verb/new_conjugacions.dart';
import 'package:my_dic/core/domain/usecase/new_fetch_conjugation/fetch_conjugation_input_data.dart';

abstract class IFetchEspConjugationUseCase {
  Future<EspConjugacions?> execute(FetchConjugationInputData input);
}
