import 'package:my_dic/features/my_word/internal/domain/entity/my_word_status.dart';

abstract class WatchMyWordStatusUsecase {
  Stream<MyWordStatus> execute(String wordId, String accountScope);
}
