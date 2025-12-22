import 'package:my_dic/features/my_word/domain/entity/my_word.dart';
import 'package:my_dic/features/my_word/domain/usecase/load_my_word/load_my_word_input_data.dart';

abstract class ILoadMyWordUseCase {
	Future<List<MyWord>> execute(LoadMyWordInputData input);
	
	
}
