import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:my_dic/features/quiz/internal/consts/card_state.dart';
import 'package:my_dic/features/quiz/internal/game/application/conjugation/quiz_conjugation.dart';
import 'package:my_dic/features/quiz/internal/game/presentation/ui_model/quiz_game_model.dart';
import 'package:my_dic/core/shared/utils/logger.dart';

/// クイズのViewModel
class QuizGameViewModel extends StateNotifier<QuizGameState> {
  // ✅ 内部状態（private）
  late QuizInternalState _internalState;
  QuizGameViewModel() : super(QuizGameState.initial()) {
    _internalState = QuizInternalState.initial();
    _updatePublicState();
  }

  // ==================== Public Methods ====================

  void inicializeQuizCardStatus() {
    _updateQuizCardStatus(QuizCardState.question);
  }

  void toggleQuizCardStatus() {
    AppLogger.print(
        "!!!!!!!!!!!!!!!!!!!!!!!!!toggleQuizCardStatus${state.quizCardState}");
    if (state.quizCardState == QuizCardState.question) {
      _updateQuizCardStatus(QuizCardState.answer);
    } else {
      _updateQuizCardStatus(QuizCardState.question);
    }
  }

  String quiz1EnglishSub(
      Map<String, String> englishSubMap,
      Map<String, Map<String, String>> beConj,
      Map<String, String> englishConj) {
    final moodTense = state.currentTense;
    final subject = state.currentSubject;
    String sub = englishSubMap[moodTense.guideKey] ?? '@ #';
    AppLogger.print("sub: $sub");

    QuizEnglishSubject englishSubject = subject.englishEquivalent;
    sub = sub.replaceAll("@", englishSubject.name);
    AppLogger.print("sub: $sub");

    QuizEnglishMoodTense englishMoodTense = moodTense.englishEquivalent;
    //@が主語
    // #が動詞

    // beがaru場合==============
    if (englishConj[QuizEnglishMoodTense.indicativePresent.wireKey] == "be") {
      //Map<String, Map<String, String>> beConj = json;
      if (moodTense == QuizMoodTense.indicativeImperfect ||
          moodTense == QuizMoodTense.indicativeFuture ||
          moodTense == QuizMoodTense.indicativeConditional ||
          moodTense == QuizMoodTense.imperative) {
        return sub.replaceAll("#", "be");
      }
      final beForm = beConj[englishMoodTense.wireKey]?[englishSubject.wireKey];
      return sub.replaceAll("#", beForm ?? "be");
    }
    final present =
        englishConj[QuizEnglishMoodTense.indicativePresent.wireKey] ?? '';
    if (present.contains("be ")) {
      if (moodTense == QuizMoodTense.indicativeImperfect ||
          moodTense == QuizMoodTense.indicativeFuture ||
          moodTense == QuizMoodTense.indicativeConditional ||
          moodTense == QuizMoodTense.imperative) {
        return sub.replaceAll("#", present);
      }
      final text = present.replaceFirst("be",
          beConj[englishMoodTense.wireKey]?[englishSubject.wireKey] ?? 'be');
      sub = sub.replaceAll(
        "#",
        text,
      );

      return sub;
    }

    // beがない場合==============
    if (englishSubject == QuizEnglishSubject.he &&
        englishMoodTense == QuizEnglishMoodTense.indicativePresent) {
      englishMoodTense = QuizEnglishMoodTense.indicativePresent3rd;
    }
    sub = sub.replaceAll("#", englishConj[englishMoodTense.wireKey] ?? '');

    return sub;
  }

  // ~~~~~~~~quiz logic~~~~~~~~~~~~~~~~~~~~~~
  /// クイズを初期化
  void initialize() {
    _internalState = QuizInternalState.initial();
    state = QuizGameState.initial();
    _updatePublicState();
    next();
  }

  /// 次の問題へ
  void next() {
    final currentIndex = state.currentIndex;
    final allLength = state.allLength;

    // すべての問題が終了
    if (allLength == 0 || currentIndex >= allLength - 1) {
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

  // ==================== Private Methods ====================

  void _updateQuizCardStatus(QuizCardState status) {
    state = state.copyWith(quizCardState: status);
  }

  /// 公開状態を更新
  void _updatePublicState() {
    state = state.copyWith(
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
    if (index < 0 || index >= _internalState.doneKeyOrder.length) return;
    final key = _internalState.doneKeyOrder[index];
    final parts = key.split('-');

    final tense = QuizMoodTense.values.firstWhere(
      (e) => e.toString() == parts[0],
      orElse: () => QuizMoodTense.indicativePresent,
    );

    final subject = QuizSubject.values.firstWhere(
      (e) => e.toString() == parts[1],
      orElse: () => QuizSubject.yo,
    );

    state = state.copyWith(
      currentIndex: index,
      currentTense: tense,
      currentSubject: subject,
    );
  }
}
