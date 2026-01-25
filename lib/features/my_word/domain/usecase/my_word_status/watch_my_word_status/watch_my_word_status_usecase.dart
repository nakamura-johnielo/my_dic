import 'package:my_dic/features/my_word/domain/entity/my_word_status.dart';

abstract class WatchMyWordStatusUsecase {
  Stream<MyWordStatus> watch(int wordId);
}
