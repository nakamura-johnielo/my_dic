import 'dart:math';
import 'package:my_dic/features/quiz/internal/consts/card_state.dart';
import 'package:my_dic/features/quiz/port/model/quiz_conjugation.dart';

/// 外部に公開する Quiz の状態（読み取り専用）
class QuizGameState {
  //TODO word,wordIdも入れる？？？

  final int currentIndex;
  final QuizMoodTense currentTense;
  final QuizSubject currentSubject;
  final int allLength;
  final QuizCardState quizCardState;

  bool get isComplete => allLength == 0 || currentIndex >= allLength - 1;
  bool get hasCurrentQuestion => currentIndex >= 0 && currentIndex < allLength;

  const QuizGameState({
    required this.currentIndex,
    required this.currentTense,
    required this.currentSubject,
    required this.allLength,
    required this.quizCardState,
  });

  QuizGameState copyWith({
    int? currentIndex,
    QuizMoodTense? currentTense,
    QuizSubject? currentSubject,
    int? allLength,
    QuizCardState? quizCardState,
  }) {
    return QuizGameState(
      currentIndex: currentIndex ?? this.currentIndex,
      currentTense: currentTense ?? this.currentTense,
      currentSubject: currentSubject ?? this.currentSubject,
      allLength: allLength ?? this.allLength,
      quizCardState: quizCardState ?? this.quizCardState,
    );
  }

  /// 初期状態
  factory QuizGameState.initial() {
    return QuizGameState(
      currentIndex: -1,
      currentTense: QuizMoodTense.indicativePresent,
      currentSubject: QuizSubject.yo,
      allLength: 0,
      quizCardState: QuizCardState.question,
    );
  }
}

/// 内部で使用するクイズの管理状態（private）
class QuizInternalState {
  final Random _random = Random();

  final List<QuizSubject> activeSubjects;
  final List<QuizMoodTense> activeMoodTenses;
  final List<(QuizMoodTense, QuizSubject)> doneKeyOrder;
  final Set<(QuizMoodTense, QuizSubject)> nonExistKeys;
  final Set<(QuizMoodTense, QuizSubject)> waitingKeys;
  final Set<(QuizMoodTense, QuizSubject)> activeKeys;

  QuizInternalState({
    List<QuizSubject>? activeSubjects,
    List<QuizMoodTense>? activeMoodTenses,
    List<(QuizMoodTense, QuizSubject)>? doneKeyOrder,
    Set<(QuizMoodTense, QuizSubject)>? nonExistKeys,
    Set<(QuizMoodTense, QuizSubject)>? waitingKeys,
    Set<(QuizMoodTense, QuizSubject)>? activeKeys,
  })  : activeSubjects = activeSubjects ?? <QuizSubject>[],
        activeMoodTenses = activeMoodTenses ?? <QuizMoodTense>[],
        doneKeyOrder = doneKeyOrder ?? <(QuizMoodTense, QuizSubject)>[],
        nonExistKeys = nonExistKeys ?? <(QuizMoodTense, QuizSubject)>{},
        waitingKeys = waitingKeys ?? <(QuizMoodTense, QuizSubject)>{},
        activeKeys = activeKeys ?? <(QuizMoodTense, QuizSubject)>{};

  QuizInternalState copyWith({
    List<QuizSubject>? activeSubjects,
    List<QuizMoodTense>? activeMoodTenses,
    List<(QuizMoodTense, QuizSubject)>? doneKeyOrder,
    Set<(QuizMoodTense, QuizSubject)>? nonExistKeys,
    Set<(QuizMoodTense, QuizSubject)>? waitingKeys,
    Set<(QuizMoodTense, QuizSubject)>? activeKeys,
  }) {
    return QuizInternalState(
      activeSubjects: activeSubjects ?? List.from(this.activeSubjects),
      activeMoodTenses: activeMoodTenses ?? List.from(this.activeMoodTenses),
      doneKeyOrder: doneKeyOrder ??
          List<(QuizMoodTense, QuizSubject)>.from(this.doneKeyOrder),
      nonExistKeys: nonExistKeys ??
          Set<(QuizMoodTense, QuizSubject)>.from(this.nonExistKeys),
      waitingKeys: waitingKeys ??
          Set<(QuizMoodTense, QuizSubject)>.from(this.waitingKeys),
      activeKeys:
          activeKeys ?? Set<(QuizMoodTense, QuizSubject)>.from(this.activeKeys),
    );
  }

  /// アクティブなキーを生成
  void updateActiveKeys() {
    final newActiveKeys = <(QuizMoodTense, QuizSubject)>{};
    final newWaitingKeys = <(QuizMoodTense, QuizSubject)>{};

    for (var moodTense in activeMoodTenses) {
      for (var subject in activeSubjects) {
        final key = (moodTense, subject);
        if (nonExistKeys.contains(key)) continue;
        newActiveKeys.add(key);
        newWaitingKeys.add(key);
      }
    }

    activeKeys.clear();
    activeKeys.addAll(newActiveKeys);
    waitingKeys.clear();
    waitingKeys.addAll(newWaitingKeys);
  }

  /// 存在しないキーを設定
  void updateNonExistKeys() {
    final int subLength = QuizSubject.values.length;

    // 現在分詞: yo以外削除
    if (activeMoodTenses.contains(QuizMoodTense.participlePresent)) {
      for (int i = 1; i < subLength; i++) {
        nonExistKeys
            .add((QuizMoodTense.participlePresent, QuizSubject.values[i]));
      }
    }

    // 過去分詞: yo以外削除
    if (activeMoodTenses.contains(QuizMoodTense.participlePast)) {
      for (int i = 1; i < subLength; i++) {
        nonExistKeys.add((QuizMoodTense.participlePast, QuizSubject.values[i]));
      }
    }

    // 命令形: yoのみ削除
    if (activeMoodTenses.contains(QuizMoodTense.imperative)) {
      nonExistKeys.add((QuizMoodTense.imperative, QuizSubject.yo));
    }
  }

  /// ランダムな整数を生成
  int random(int max) {
    if (max <= 0) return 0;
    return _random.nextInt(max);
  }

  /// 初期状態を作成
  factory QuizInternalState.initial() {
    final state = QuizInternalState(
      activeSubjects: List.from(QuizSubject.values),
      activeMoodTenses: List.from(QuizMoodTense.values),
    );
    state.updateNonExistKeys();
    state.updateActiveKeys();
    return state;
  }
}
