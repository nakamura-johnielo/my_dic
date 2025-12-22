import 'package:my_dic/features/my_word/domain/usecase/load_my_word/load_my_word_output_data.dart';

abstract class ILoadMyWordPresenter {
	void execute(LoadMyWordOutputData input);
	
	
}
