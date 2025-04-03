import 'package:my_dic/_Business_Rule/Usecase/load_my_word/load_my_word_input_data.dart';
import 'package:my_dic/_Business_Rule/Usecase/load_my_word/i_load_my_word_use_case.dart';
import 'package:my_dic/_Business_Rule/Usecase/load_my_word/load_my_word_output_data.dart';
import 'package:my_dic/_Business_Rule/Usecase/load_my_word/i_load_my_word_presenter.dart';
import 'package:my_dic/_Business_Rule/Usecase/load_my_word/load_my_word_repository_input_data.dart';
import 'package:my_dic/_Business_Rule/_Domain/Entities/my_word.dart';
import 'package:my_dic/_Business_Rule/_Domain/Repository_I/i_load_my_word_repository.dart';

class LoadMyWordInteractor implements ILoadMyWordUseCase {
  final ILoadMyWordPresenter _loadMyWordPresenterImpl;
  final ILoadMyWordRepository _driftLoadMyWordRepository;

  LoadMyWordInteractor(
      this._loadMyWordPresenterImpl, this._driftLoadMyWordRepository);

  @override
  void execute(LoadMyWordInputData input) async {
    int offset = input.currentLastPages * input.size;
    LoadMyWordRepositoryInputData repositoryInput =
        LoadMyWordRepositoryInputData(input.size, offset);
    List<MyWord> data =
        await _driftLoadMyWordRepository.getFilteredByPage(repositoryInput);

    //String data1 =await _driftLoadMyWordRepository.getById(input.id);

    LoadMyWordOutputData output = LoadMyWordOutputData(data);
    _loadMyWordPresenterImpl.execute(output);
  }
}
