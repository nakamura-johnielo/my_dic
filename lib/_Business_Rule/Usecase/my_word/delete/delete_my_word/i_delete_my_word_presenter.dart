import 'package:my_dic/_Business_Rule/Usecase/my_word/delete/delete_my_word/delete_my_word_output_data.dart';

abstract class IDeleteMyWordPresenter {
  void execute(DeleteMyWordOutputData input);
}
