import 'package:my_dic/_Business_Rule/Usecase/fetch_conjugation/fetch_conjugation_input_data.dart';

abstract class IFetchConjugationUseCase {
  Future<void> execute(FetchConjugationInputData input);
}
