import 'package:my_dic/core/domain/usecase/fetch_conjugation/fetch_conjugation_output_data.dart';

abstract class IFetchConjugationPresenter {
  void execute(FetchConjugationOutputData input);
}
