import 'package:my_dic/core/domain/entity/verb/conjugacions.dart';
import 'package:my_dic/core/domain/usecase/fetch_conjugation/fetch_conjugation_input_data.dart';
import 'package:my_dic/core/shared/utils/result.dart';

abstract class IFetchEspConjugationUseCase {
  Future<Result<EspConjugacions?>> execute(FetchConjugationInputData input);
}
