import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:my_dic/Constants/Enums/cardState.dart';
import 'package:my_dic/core/common/enums/conjugacion/mood_tense.dart';
import 'package:my_dic/core/common/enums/conjugacion/subject.dart';
import 'package:my_dic/core/domain/entity/verb/conjugacion/conjugacions.dart';
import 'package:my_dic/core/domain/usecase/fetch_conjugation/fetch_conjugation_input_data.dart';
import 'package:my_dic/core/domain/usecase/fetch_conjugation/i_fetch_conjugation_use_case.dart';
import 'package:my_dic/features/quiz/domain/usecase/fetch_english_conj.dart/i_fetch_english_conj_usecase.dart';
import 'package:my_dic/features/quiz/presentation/ui_model/new_quiz_model.dart';

/// クイズのViewModel
class QuizViewModel extends StateNotifier<QuizState> {
  // ✅ 内部状態（private）
  late QuizInternalState _internalState;
  final IFetchConjugationUseCase _fetchConjugationInteractor;
  final IFetchEnglishConjUseCase _fetchEnglishConjInteractor;

  QuizViewModel(
      this._fetchConjugationInteractor, this._fetchEnglishConjInteractor)
      : super(QuizState.initial()) {
    _internalState = QuizInternalState.initial();
    _updatePublicState();
  }

  // ==================== Public Methods ====================


  void inicializeQuizCardStatus(){
     _updateQuizCardStatus( QuizCardState.question);
  }

  void toggleQuizCardStatus(){
    print("!!!!!!!!!!!!!!!!!!!!!!!!!toggleQuizCardStatus${state.quizCardState}");
    if(state.quizCardState == QuizCardState.question){
      _updateQuizCardStatus( QuizCardState.answer);
    }else{
     _updateQuizCardStatus( QuizCardState.question);
    }
  }

  Future<Map<String, String>> fetchEnglishConj(int wordId) async {
    final englishConj = await _fetchEnglishConjInteractor.execute(wordId);
    print("!!!!!!!!!!!!!!!!!!!!!!!!!englishConj in QuizController");
    print(englishConj);
    return englishConj;
  }

  Future<Conjugacions?> getConjugaciones(int wordId) async {
    final FetchConjugationInputData input = FetchConjugationInputData(wordId);
    final FetchConjugationInputData inputDef =
        FetchConjugationInputData(61663); //ser
    final res = await _fetchConjugationInteractor.executeReturn(input) ??
        _fetchConjugationInteractor.executeReturn(inputDef);
    if (res is Conjugacions) {
      return res;
    }
    return null;
  }

  String quiz1EnglishSub(
      Map<String, String> englishSubMap,
      Map<String, Map<String, String>> beConj,
      Map<String, String> englishConj) {
    final moodTense = state.currentTense;
    final subject = state.currentSubject;
    String sub =
        englishSubMap[moodTense.toString()]!; //"It's important that @ #"
    print("sub: $sub");

    EnglishSubject englishSubject = subject.equiEnglish;
    sub = sub.replaceAll("@", englishSubject.name);
    print("sub: $sub");

    EnglishMoodTense englishMoodTense = moodTense.equiEnglish;
    //@が主語
    // #が動詞

    //print("=================beConj");
    //print(englishConj);
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
      // print("BEsub: $sub");
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
      //print("BEsub: $sub");
      return sub;
    }

    // beがない場合==============
    if (englishSubject == EnglishSubject.he &&
        englishMoodTense == EnglishMoodTense.indicativePresent) {
      englishMoodTense = EnglishMoodTense.indicativePresent3rd;
    }
    sub = sub.replaceAll("#", englishConj[englishMoodTense.toString()]!);
    //rprint("sub: $sub");
    return sub;
  }

  // ~~~~~~~~quiz logic~~~~~~~~~~~~~~~~~~~~~~
  /// クイズを初期化
  void initialize() {
    _internalState = QuizInternalState.initial();
    state = QuizState.initial();
    _updatePublicState();
    next();
  }

  /// 次の問題へ
  void next() {
    final currentIndex = state.currentIndex;
    final allLength = state.allLength;

    // すべての問題が終了
    if (allLength == currentIndex + 1) {
      return;
    }

    final newIndex = currentIndex + 1;

    // 新規問題を生成
    if (newIndex >= _internalState.doneKeyOrder.length) {
      _generateNextQuestion();
    }

    // 問題を設定
    _setCurrentQuestion(newIndex);
  }

  /// 前の問題へ戻る
  bool back() {
    if (state.currentIndex > 0) {
      _setCurrentQuestion(state.currentIndex - 1);
      return true;
    }
    return false;
  }

  /// アクティブなアイテムを設定
  // void setActiveItems(bool isActive, Enum item) {
  //   if (item is Subject) {
  //     _updateActiveSubjects(isActive, item);
  //   } else if (item is MoodTense) {
  //     _updateActiveMoodTenses(isActive, item);
  //   }
  //   _internalState.updateActiveKeys();
  //   _updatePublicState();
  // }

  // ==================== Private Methods ====================

  void _updateQuizCardStatus(QuizCardState status) {
    state = state.copyWith(quizCardState: status);
  }

  /// 公開状態を更新
  void _updatePublicState() {
    state = state.copyWith(
      // currentIndex: state.currentIndex,
      // currentTense: state.currentTense,
      // currentSubject: state.currentSubject,
      allLength: _internalState.activeKeys.length,
    );
  }

  /// 次の問題を生成
  void _generateNextQuestion() {
    if (_internalState.waitingKeys.isEmpty) return;

    final randomIndex =
        _internalState.random(_internalState.waitingKeys.length);
    final key = _internalState.waitingKeys.elementAt(randomIndex);

    _internalState.waitingKeys.remove(key);
    _internalState.doneKeyOrder.add(key);
  }

  /// 現在の問題を設定
  void _setCurrentQuestion(int index) {
    final key = _internalState.doneKeyOrder[index];
    final parts = key.split('-');

    final tense = MoodTense.values.firstWhere(
      (e) => e.toString() == parts[0],
      orElse: () => MoodTense.indicativePresent,
    );

    final subject = Subject.values.firstWhere(
      (e) => e.toString() == parts[1],
      orElse: () => Subject.yo,
    );

    state = state.copyWith(
      currentIndex: index,
      currentTense: tense,
      currentSubject: subject,
    );
  }

  /// アクティブな主語を更新
  void _updateActiveSubjects(bool isActive, Subject subject) {
    if (isActive) {
      if (!_internalState.activeSubjects.contains(subject)) {
        _internalState.activeSubjects.add(subject);
      }
    } else {
      _internalState.activeSubjects.remove(subject);
    }
  }

  /// アクティブな時制を更新
  void _updateActiveMoodTenses(bool isActive, MoodTense tense) {
    if (isActive) {
      if (!_internalState.activeMoodTenses.contains(tense)) {
        _internalState.activeMoodTenses.add(tense);
      }
    } else {
      _internalState.activeMoodTenses.remove(tense);
    }
  }
}
