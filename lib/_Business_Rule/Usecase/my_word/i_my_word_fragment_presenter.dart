import 'package:my_dic/_Business_Rule/Usecase/my_word/create/register_my_word/register_my_word_output_data.dart';
import 'package:my_dic/_Business_Rule/Usecase/my_word/delete/delete_my_word/delete_my_word_output_data.dart';
import 'package:my_dic/_Business_Rule/Usecase/my_word/update/update_my_word/update_my_word_output_data.dart';

abstract class IMyWordFragmentPresenter {
  void completeRegistration(RegisterMyWordOutputData input);
  void completeUpdate(UpdateMyWordOutputData input);
  void completeDelete(DeleteMyWordOutputData input);
}
