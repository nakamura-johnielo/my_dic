import 'package:my_dic/features/my_word/domain/entity/my_word.dart';

class MyWordState {
  final List<MyWord> myWords;
  MyWordState({this.myWords=const[]});

  MyWordState copyWith({List<MyWord>? myWords}) {
    return MyWordState(myWords: myWords ?? this.myWords);
  }
}
