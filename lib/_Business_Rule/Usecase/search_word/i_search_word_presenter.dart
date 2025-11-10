import 'package:my_dic/_Business_Rule/Usecase/search_word/search_word_output_data.dart';

abstract class ISearchWordPresenter {
  void executNextEspJpn(SearchWordOutputData input);
  void executeNextJpnEsp(SearchJpnEspWordOutputData input);
  void executNextConjugacion(SearchConjugacionOutputData input);
  void executInicialEspJpn(SearchWordOutputData input);
  void executeInicialJpnEsp(SearchJpnEspWordOutputData input);
  void executInicialConjugacion(SearchConjugacionOutputData input);
}
