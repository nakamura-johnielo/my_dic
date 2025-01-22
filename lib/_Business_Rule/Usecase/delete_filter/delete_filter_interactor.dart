import 'package:my_dic/_Business_Rule/Usecase/delete_filter/delete_filter_input_data.dart';
import 'package:my_dic/_Business_Rule/Usecase/delete_filter/delete_filter_output_data.dart';
import 'package:my_dic/_Business_Rule/Usecase/delete_filter/i_delete_filter_presenter.dart';
import 'package:my_dic/_Business_Rule/Usecase/delete_filter/i_delete_filter_use_case.dart';

class DeleteFilterInteractor implements IDeleteFilterUseCase {
  final IDeleteFilterPresenter _deleteFilterPresenterImpl;

  DeleteFilterInteractor(this._deleteFilterPresenterImpl);

  @override
  void execute(DeleteFilterInputData input) {
    DeleteFilterOutputData d = DeleteFilterOutputData(input.filter);
    _deleteFilterPresenterImpl.execute(d);
  }
}
