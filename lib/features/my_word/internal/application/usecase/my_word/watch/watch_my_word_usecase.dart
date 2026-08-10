import 'package:my_dic/features/my_word/internal/domain/entity/my_word.dart';

abstract class WatchMyWordUsecase {
  Stream<MyWord> execute(String wordId, String accountScope);
}
