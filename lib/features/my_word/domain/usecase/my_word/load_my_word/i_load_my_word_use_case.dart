import 'package:my_dic/core/shared/utils/result.dart';
import 'package:my_dic/features/my_word/domain/entity/my_word.dart';
import 'package:my_dic/features/my_word/domain/usecase/my_word/load_my_word/load_my_word_input_data.dart';

abstract class ILoadMyWordUseCase {
  Future<Result<List<MyWord>>> execute(LoadMyWordInputData input);
  Future<Result<List<String>>> executeIds(LoadMyWordInputData input);
  // Future<Result<MyWord>> getMyWordById(int id);
}
