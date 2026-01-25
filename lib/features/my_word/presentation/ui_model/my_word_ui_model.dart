import 'package:my_dic/features/my_word/domain/entity/my_word.dart';

// class MyWordStateOld {
//   final List<MyWord> myWords;
//   MyWordStateOld({this.myWords=const[]});

//   MyWordStateOld copyWith({List<MyWord>? myWords}) {
//     return MyWordStateOld(myWords: myWords ?? this.myWords);
//   }
// }

// class MyWordState {
//   final MyWord myWords;
//   //MyWordState({this.myWords }):super(MyWord(wordId:0,word:'',contents:''));

//   MyWordState({required this.myWords});
//   MyWordState copyWith({MyWord? myWords}) {
//     return MyWordState(myWords: myWords ?? this.myWords);
//   }
// }

class MyWordStateNew {
  final List<int> myWordIds;
  MyWordStateNew({this.myWordIds=const[]});

  MyWordStateNew copyWith({List<int>? myWordIds}) {
    return MyWordStateNew(myWordIds: myWordIds ?? this.myWordIds);
  }
}
