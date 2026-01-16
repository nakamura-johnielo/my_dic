import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:my_dic/core/di/router/router.dart';
import 'package:my_dic/core/shared/enums/entry_point.dart';
import 'package:my_dic/features/auth/di/service.dart';
import 'package:my_dic/features/quiz/presentation/view/quiz_game_fragment.dart';
import 'package:my_dic/features/word_page/presentation/view/word_page_fragment.dart';
import 'package:my_dic/router/route_names.dart';
import 'package:my_dic/router/router.dart';

final appNavigatorServiceProvider = Provider<AppNavigatorService>((ref) {
  return AppNavigatorService(ref);
});

class AppNavigatorService {
  AppNavigatorService(this.ref);
  final Ref ref;

  GoRouter get _router => ref.read(routerProvider);

  EntryPoint get _entryPoint => ref.read(entryPointProvider);

  String _getFormerName() {
    switch (_entryPoint) {
      case EntryPoint.search:
        return RouteNames.search;
      case EntryPoint.studyDashboard:
        return RouteNames.dashboard;
      case EntryPoint.studyRanking:
        return RouteNames.ranking;
      case EntryPoint.studyQuiz:
        return RouteNames.quiz;
      case EntryPoint.myword:
        return RouteNames.myWord;
      case EntryPoint.profile:
        return RouteNames.profile;
    }
  }

  void toWordDetail(WordPageInput input) {
    _router.pushNamed('${_getFormerName()}-${RouteNames.wordDetail}',
        extra: input);
  }

  void toFlashCard(QuizGameFragmentInput input) {
    _router.pushNamed('${_getFormerName()}-${RouteNames.flashCard}',
        extra: input);
  }

  // 戻る
  void pop() {
    _router.pop();
  }

  //

  // 指定エントリーポイントに対応するNavigatorKeyを返す
  GlobalKey<NavigatorState>? _navigatorKeyForEntryPoint(EntryPoint entry) {
    switch (entry) {
      case EntryPoint.search:
        return ref.read(searchNavigatorKeyProvider);
      case EntryPoint.studyDashboard:
        return ref.read(studyDashboardNavigatorKeyProvider);
      case EntryPoint.studyRanking:
        return ref.read(studyRankingNavigatorKeyProvider);
      case EntryPoint.studyQuiz:
        return ref.read(studyQuizNavigatorKeyProvider);
      case EntryPoint.myword:
        return ref.read(myWordNavigatorKeyProvider);
      case EntryPoint.profile:
        return ref.read(profileNavigatorKeyProvider);
    }
  }

  // 指定エントリーポイントのルート名を返す（_getFormerName の汎用版）
  String _routeNameForEntryPoint(EntryPoint entry) {
    switch (entry) {
      case EntryPoint.search:
        return RouteNames.search;
      case EntryPoint.studyDashboard:
        return RouteNames.dashboard;
      case EntryPoint.studyRanking:
        return RouteNames.ranking;
      case EntryPoint.studyQuiz:
        return RouteNames.quiz;
      case EntryPoint.myword:
        return RouteNames.myWord;
      case EntryPoint.profile:
        return RouteNames.profile;
    }
  }

  // 指定したブランチのNavigatorスタックをクリアして、そのブランチの初期ルートに戻す
  void clearBranchHistoryAndGoRoot(EntryPoint entry) {
    final key = _navigatorKeyForEntryPoint(entry);
    // Navigator が存在すれば内部スタックを先頭まで戻す
    key?.currentState?.popUntil((route) => route.isFirst);

    // // ブランチの初期画面に遷移（named route を使用）
    // final name = _routeNameForEntryPoint(entry);
    // try {
    //   _router.goNamed(name);
    // } catch (_) {
    //   // 名前付きルートが設定されていないケースに備え pushNamed を試す
    //   _router.pushNamed(name);
    // }
  }

  // 現在の entryPoint に対してクリア→ルート遷移を行うショートカット
  void clearCurrentBranchHistoryAndGoRoot() {
    clearBranchHistoryAndGoRoot(_entryPoint);
  }

  void toProfile() {
    print('========-Go to profile========');
      _router.replaceNamed(RouteNames.unauthorized);
     

    // login系のページじゃなければ強勢移動させない
  //   final inProfile = _entryPoint == EntryPoint.profile;
  //   if (!inProfile) return;

  //   final auth = ref.read(authStoreNotifierProvider);

  //   if (auth == null) {
  //     print('auth is null');
  //     _router.replaceNamed(RouteNames.unauthorized);
  //     return;
  //   }

  //   final loggedIn = auth.isLogined;
  //   final verified = auth.isAuthenticated;
  //   print('loggedIn: $loggedIn, verified: $verified');

  //   if (!loggedIn || !verified) {
  //     _router.replaceNamed(RouteNames.unauthorized);
  //     return;
  //   }
  //     _router.replaceNamed(RouteNames.authorized);
  //     return;
   }
}
