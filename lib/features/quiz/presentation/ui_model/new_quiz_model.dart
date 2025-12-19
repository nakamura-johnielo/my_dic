import 'dart:math';
import 'package:my_dic/Constants/Enums/cardState.dart';
import 'package:my_dic/core/common/enums/conjugacion/mood_tense.dart';
import 'package:my_dic/core/common/enums/conjugacion/subject.dart';

/// 外部に公開する Quiz の状態（読み取り専用）
class QuizState {
  final int currentIndex;
  final MoodTense currentTense;
  final Subject currentSubject;
  final int allLength;
  final QuizCardState quizCardState;

  const QuizState({
    required this.currentIndex,
    required this.currentTense,
    required this.currentSubject,
    required this.allLength,
    required this.quizCardState,
  });

  QuizState copyWith({
    int? currentIndex,
    MoodTense? currentTense,
    Subject? currentSubject,
    int? allLength,
    QuizCardState? quizCardState,
  }) {
    return QuizState(
      currentIndex: currentIndex ?? this.currentIndex,
      currentTense: currentTense ?? this.currentTense,
      currentSubject: currentSubject ?? this.currentSubject,
      allLength: allLength ?? this.allLength,
      quizCardState: quizCardState ?? this.quizCardState,
    );
  }

  /// 初期状態
  factory QuizState.initial() {
    return QuizState(
      currentIndex: -1,
      currentTense: MoodTense.indicativePresent,
      currentSubject: Subject.yo,
      allLength: 0,
      quizCardState: QuizCardState.question,
    );
  }
}

/// 内部で使用するクイズの管理状態（private）
class QuizInternalState {
  final Random _random = Random();

  final List<Subject> activeSubjects;
  final List<MoodTense> activeMoodTenses;
  final List<String> doneKeyOrder;
  final Set<String> nonExistKeys;
  final Set<String> waitingKeys;
  final Set<String> activeKeys;

  QuizInternalState({
    List<Subject>? activeSubjects,
    List<MoodTense>? activeMoodTenses,
    List<String>? doneKeyOrder,
    Set<String>? nonExistKeys,
    Set<String>? waitingKeys,
    Set<String>? activeKeys,
  })  : activeSubjects = activeSubjects ?? [],
        activeMoodTenses = activeMoodTenses ?? [],
        doneKeyOrder = doneKeyOrder ?? [],
        nonExistKeys = nonExistKeys ?? {},
        waitingKeys = waitingKeys ?? {},
        activeKeys = activeKeys ?? {};

  QuizInternalState copyWith({
    List<Subject>? activeSubjects,
    List<MoodTense>? activeMoodTenses,
    List<String>? doneKeyOrder,
    Set<String>? nonExistKeys,
    Set<String>? waitingKeys,
    Set<String>? activeKeys,
  }) {
    return QuizInternalState(
      activeSubjects: activeSubjects ?? List.from(this.activeSubjects),
      activeMoodTenses: activeMoodTenses ?? List.from(this.activeMoodTenses),
      doneKeyOrder: doneKeyOrder ?? List.from(this.doneKeyOrder),
      nonExistKeys: nonExistKeys ?? Set.from(this.nonExistKeys),
      waitingKeys: waitingKeys ?? Set.from(this.waitingKeys),
      activeKeys: activeKeys ?? Set.from(this.activeKeys),
    );
  }

  /// アクティブなキーを生成
  void updateActiveKeys() {
    final newActiveKeys = <String>{};
    final newWaitingKeys = <String>{};

    for (var moodTense in activeMoodTenses) {
      for (var subject in activeSubjects) {
        String key = '$moodTense-$subject';
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
    final int subLength = Subject.values.length;

    // 現在分詞: yo以外削除
    if (activeMoodTenses.contains(MoodTense.participlePresent)) {
      for (int i = 1; i < subLength; i++) {
        nonExistKeys.add(
          '${MoodTense.participlePresent}-${Subject.values[i]}',
        );
      }
    }

    // 過去分詞: yo以外削除
    if (activeMoodTenses.contains(MoodTense.participlePast)) {
      for (int i = 1; i < subLength; i++) {
        nonExistKeys.add(
          '${MoodTense.participlePast.toString()}-${Subject.values[i].toString()}',
        );
      }
    }

    // 命令形: yoのみ削除
    if (activeMoodTenses.contains(MoodTense.imperative)) {
      nonExistKeys.add(
        '${MoodTense.imperative.toString()}-${Subject.yo.toString()}',
      );
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
      activeSubjects: List.from(Subject.values),
      activeMoodTenses: List.from(MoodTense.values),
    );
    state.updateNonExistKeys();
    state.updateActiveKeys();
    return state;
  }
}
