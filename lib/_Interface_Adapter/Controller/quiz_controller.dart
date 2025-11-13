import 'dart:math';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:my_dic/Constants/Enums/mood_tense.dart';
import 'package:my_dic/Constants/Enums/subject.dart';
import 'package:my_dic/DI/product.dart';
import 'package:my_dic/_Business_Rule/Usecase/fetch_conjugation/fetch_conjugation_input_data.dart';
import 'package:my_dic/_Business_Rule/Usecase/fetch_conjugation/i_fetch_conjugation_use_case.dart';
import 'package:my_dic/_Business_Rule/_Domain/Entities/verb/conjugacion/conjugacions.dart';
import 'package:my_dic/_Framework_Driver/Repository/drift_es_en_conjugacions_repository.dart';

class QuizController {
  final DriftEsEnConjugacionRepository _driftEsEnConjugacionRepository;
  QuizController(this._driftEsEnConjugacionRepository);
  //Map<String, String> englishConj = {};
  Future<Map<String, String>> fetchEnglishConj(int wordId) async {
    final englishConj =
        await _driftEsEnConjugacionRepository.getEnglishConjById(wordId);
    print("!!!!!!!!!!!!!!!!!!!!!!!!!englishConj in QuizController");
    print(englishConj);
    return englishConj;
  }

  Future<Conjugacions?> getConjugaciones(int wordId) async {
    // doneSet.clear();
    //Map<MoodTense, TenseConjugacion> conjugacions;
    final fetchconj = DI<IFetchConjugationUseCase>();
    final FetchConjugationInputData input = FetchConjugationInputData(wordId);
    final FetchConjugationInputData inputDef =
        FetchConjugationInputData(61663); //ser
    final res = await fetchconj.executeReturn(input) ??
        fetchconj.executeReturn(inputDef);
    if (res is Conjugacions) {
      //conjugacions = res;
      return res;
    }
    return null;
    // if (res is Conjugacions) {
    //   conjugacions = res;
    // }
    //conjugacions = res;
    //
  }

  String quiz1EnglishSub(
      Map<String, String> englishSubMap,
      Map<String, Map<String, String>> beConj,
      Map<String, String> englishConj,
      MoodTense moodTense,
      Subject subject) {
    String sub =
        englishSubMap[moodTense.toString()]!; //"It's important that @ #"
    print("sub: $sub");

    EnglishSubject englishSubject = subject.equiEnglish;
    sub = sub.replaceAll("@", englishSubject.name);
    print("sub: $sub");

    EnglishMoodTense englishMoodTense = moodTense.equiEnglish;
    //@が主語
    // #が動詞

    print("=================beConj");
    print(englishConj);
    // beがaru場合==============
    if (englishConj[EnglishMoodTense.indicativePresent.toString()] == "be") {
      //Map<String, Map<String, String>> beConj = json;
      if (moodTense == MoodTense.indicativeImperfect ||
          moodTense == MoodTense.indicativeFuture ||
          moodTense == MoodTense.indicativeConditional ||
          moodTense == MoodTense.imperative) {
        return sub.replaceAll("#", "be");
      }
      sub = sub.replaceAll("#",
          beConj[englishMoodTense.toString()]![englishSubject.toString()]!);
      print("BEsub: $sub");
      return sub;
    }
    if (englishConj[EnglishMoodTense.indicativePresent.toString()]!
        .contains("be ")) {
      //Map<String, Map<String, String>> beConj = json;
      if (moodTense == MoodTense.indicativeImperfect ||
          moodTense == MoodTense.indicativeFuture ||
          moodTense == MoodTense.indicativeConditional ||
          moodTense == MoodTense.imperative) {
        return sub.replaceAll(
            "#", englishConj[EnglishMoodTense.indicativePresent.toString()]!);
      }
      final text = englishConj[EnglishMoodTense.indicativePresent.toString()]!
          .replaceFirst("be",
              beConj[englishMoodTense.toString()]![englishSubject.toString()]!);
      sub = sub.replaceAll(
        "#",
        text,
      );
      print("BEsub: $sub");
      return sub;
    }

    // beがない場合==============
    if (englishSubject == EnglishSubject.he &&
        englishMoodTense == EnglishMoodTense.indicativePresent) {
      englishMoodTense = EnglishMoodTense.indicativePresent3rd;
    }
    sub = sub.replaceAll("#", englishConj[englishMoodTense.toString()]!);
    print("sub: $sub");
    return sub;
  }

  //String grammer() {}
}

/////
//////
///

//final quizConjugacionsProvider = StateProvider<Conjugacions?>((ref) => null);

// final quizConjugacionsProvider = FutureProvider.autoDispose
//     <Conjugacions?>((ref) async {
//   final quizState = ref.watch(quizStateProvider);
//   final controller = QuizController();
//   // quizState.currentWordIdなど必要なIDを使う
//   return await controller.getConjugaciones(quizState.currentWordId);
// });

final quizConjugacionsProvider =
    FutureProvider.autoDispose.family<Conjugacions?, int>(
  (ref, wordId) async {
    final controller = DI<QuizController>();
    return await controller.getConjugaciones(wordId);
  },
);

final quizWordProvider = StateProvider<String>((ref) => "");

// QuizStateをRiverpodで管理するProvider
final quizStateProvider = StateNotifierProvider<QuizStateNotifier, QuizState>(
  (ref) => QuizStateNotifier(),
);

class QuizStateNotifier extends StateNotifier<QuizState> {
  QuizStateNotifier() : super(QuizState()) {
    state.init();
    //state = state;
  }

  void init() {
    state.init();
    state = state;
    state = state.copy();
  }

  // QuizStateのメソッドをラップして必要に応じてstateを更新
  void quiz1Next() {
    state.quiz1Next();
    print(state.currentTense.name);
    print(state.currentSubject.name);
    state = state; // 状態更新通知
    state = state.copy();
  }

  void quiz1Back() {
    bool res = state.quiz1Back();
    print(state.currentTense.name);
    print(state.currentSubject.name);
    if (res) {
      state = state; // 状態更新通知
      state = state.copy();
    }
  }

  void clearDoneSet() {
    state.doneSet.clear();
    state = state;
    state = state.copy();
  }

  // 必要に応じて他の操作も追加
}

class QuizState {
  //Conjugacions? conjugacions;
  final int _moodTenseLength = MoodTense.values.length;
  final int _subjectLength = Subject.values.length;
  final _random = Random();
  final int allLength =
      Subject.values.length * (MoodTense.values.length - 2) + 2 - 1;
  //Conjugacions doneItems;
  int wordId = 0;
  List<String> doneSet = [];
  int currentIndex = -1;
  Set<String> nonexistSet = {};
  MoodTense currentTense = MoodTense.indicativePresent;
  Subject currentSubject = Subject.yo;

  QuizState copy() {
    final cloned = QuizState();
    cloned.doneSet = List<String>.from(doneSet);
    cloned.currentIndex = currentIndex;
    cloned.nonexistSet = Set<String>.from(nonexistSet);
    cloned.currentTense = currentTense;
    cloned.currentSubject = currentSubject;
    cloned.wordId = wordId;
    return cloned;
  }

  void init() {
    currentTense = MoodTense.indicativePresent;
    currentSubject = Subject.yo;
    currentIndex = -1;

    doneSet.clear();
    nonexistSet.clear();
    // 分詞はyoのみ
    MoodTense moodTensePresent = MoodTense.participlePresent;
    for (int i = 1; i < _subjectLength; i++) {
      Subject subject = Subject.values[i];
      String key = '$moodTensePresent-$subject';
      nonexistSet.add(key);
    }
    MoodTense moodTensePast = MoodTense.participlePast;
    for (int i = 1; i < _subjectLength; i++) {
      Subject subject = Subject.values[i];
      String key = '$moodTensePast-$subject';
      nonexistSet.add(key);
    }
    nonexistSet.add('MoodTense.imperative-Subject.yo');
    quiz1Next();
  }

  bool quiz1Back() {
    if (currentIndex > 0) {
      print("BAAAAAAAAAAAAAACK");
      currentIndex -= 1;
      List<String> last = doneSet[currentIndex].split('-');
      currentTense =
          MoodTense.values.firstWhere((e) => e.toString() == last[0]);
      currentSubject =
          Subject.values.firstWhere((e) => e.toString() == last[1]);
      return true;
    }
    return false;
  }
  // void initicalize(int wordId) async {
  //   doneSet.clear();
  //   //Map<MoodTense, TenseConjugacion> conjugacions;
  //   final fetchconj = DI<IFetchConjugationUseCase>();
  //   final FetchConjugationInputData input = FetchConjugationInputData(wordId);
  //   final FetchConjugationInputData inputDef =
  //       FetchConjugationInputData(61663); //ser
  //   final res = await fetchconj.executeReturn(input) ??
  //       fetchconj.executeReturn(inputDef);
  //   if (res is Conjugacions) {
  //     conjugacions = res;
  //   }
  //   //conjugacions = res;
  //   //
  // }

  // yo + future ->
  void quiz1Next() {
    print("quiz1");
    //主語＋時制
    //スペイン語を答える
    currentIndex += 1;

    if (currentIndex >= doneSet.length) {
      print("===================quiz1Next");
      // ランダムで時制と主語選定
      String key = getRandomKey();
      //currentTense = MoodTense.values[int.parse(key.split('-')[0])];

      doneSet.add(key); // 出題済みに追加
      return;
    }
    print("===================quiz1Next recover");

    List<String> last = doneSet[currentIndex].split('-');
    currentTense = MoodTense.values.firstWhere((e) => e.toString() == last[0]);
    currentSubject = Subject.values.firstWhere((e) => e.toString() == last[1]);
  }

  String getRandomKey() {
    // ランダムで時制と主語選定

    int moodTenseIndex = random(_moodTenseLength);
    int subjectIndex = random(_subjectLength);
    MoodTense moodTense = MoodTense.values[moodTenseIndex];
    Subject subject = Subject.values[subjectIndex];
    String key = '$moodTense-$subject';

    while (doneSet.contains(key) || nonexistSet.contains(key)) {
      int moodTenseIndex = random(_moodTenseLength);
      int subjectIndex = random(_subjectLength);
      moodTense = MoodTense.values[moodTenseIndex];
      subject = Subject.values[subjectIndex];
      key = '$moodTense-$subject';
    }

    //doneSet.add(key); // 出題済みに追加
    currentTense = moodTense;
    currentSubject = subject;

    return key;
  }

  int random(int max) {
    int number = _random.nextInt(max - 1); // 0〜max-1の整数を返す
    return number;
  }
}
