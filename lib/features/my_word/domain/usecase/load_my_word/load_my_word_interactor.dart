import 'package:my_dic/features/my_word/domain/usecase/load_my_word/load_my_word_input_data.dart';
import 'package:my_dic/features/my_word/domain/usecase/load_my_word/i_load_my_word_use_case.dart';
import 'package:my_dic/features/my_word/domain/usecase/load_my_word/load_my_word_repository_input_data.dart';
import 'package:my_dic/features/my_word/domain/entity/my_word.dart';
import 'package:my_dic/features/my_word/domain/i_repository/i_my_word_repository.dart';

class LoadMyWordInteractor implements ILoadMyWordUseCase {
  final IMyWordRepository _driftLoadMyWordRepository;

  LoadMyWordInteractor( this._driftLoadMyWordRepository);

  @override
  Future<List<MyWord>> execute(LoadMyWordInputData input) async {
    int offset = input.requiredPage * input.size;
    LoadMyWordRepositoryInputData repositoryInput =
        LoadMyWordRepositoryInputData(input.size, offset);
    List<MyWord> data =
        await _driftLoadMyWordRepository.getFilteredByPage(repositoryInput);

    //String data1 =await _driftLoadMyWordRepository.getById(input.id);

    // LoadMyWordOutputData output = LoadMyWordOutputData(data);
    // _loadMyWordPresenterImpl.execute(output);
    return data;
  }
}
