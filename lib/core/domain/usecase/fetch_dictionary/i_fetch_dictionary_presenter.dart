import 'package:my_dic/core/domain/usecase/fetch_dictionary/fetch_dictionary_output_data.dart';

abstract class IFetchDictionaryPresenter {
  void execute(FetchDictionaryOutputData input);
}
