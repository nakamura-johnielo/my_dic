import 'package:my_dic/_Business_Rule/Usecase/fetch_jpn_esp_dictionary/fetch_jpn_esp_dictionary_output_data.dart';
import 'package:my_dic/_Business_Rule/Usecase/fetch_jpn_esp_dictionary/i_fetch_jpn_esp_dictionary_presenter.dart';
import 'package:my_dic/_Interface_Adapter/ViewModel/jpn_esp_word_page_view_model.dart';

class JpnEspWordPagePresenterImpl implements IFetchJpnEspDictionaryPresenter {
  final JpnEspWordPageViewModel _wordPageViewmodel;

  JpnEspWordPagePresenterImpl(this._wordPageViewmodel);

  @override
  void executeFetch(FetchJpnEspDictionaryOutputData input) {
    _wordPageViewmodel.setDictionaryCache(input.id, input.items);
  }
}
