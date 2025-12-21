import 'package:my_dic/_Business_Rule/Usecase/my_word/create/handle_word_registration/handle_word_registration_input_data.dart';
import 'package:my_dic/_Business_Rule/Usecase/my_word/create/handle_word_registration/i_handle_word_registration_use_case.dart';

class HandleWordRegistrationInteractor
    implements IHandleWordRegistrationUseCase {
  //final IMyWordFragmentPresenter _presenterImpl;
  //HandleWordRegistrationInteractor(this._presenterImpl);
  HandleWordRegistrationInteractor();

  @override
  void execute(HandleWordRegistrationInputData input) {
    if (input.isSuccess) {
      handleWithSuccess(input.onComplete);
      return;
    }

    handleWithError(input.onError);
  }

  void handleWithSuccess(void Function() onComplete) {
    //modal textfield clear modal内のUI動作
    onComplete();
    //success dialog
    // close  modal
  }

  void handleWithError(void Function() onError) {
    onError();
  }
}
