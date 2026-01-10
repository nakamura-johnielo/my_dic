import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:my_dic/core/di/router/router.dart';
import 'package:my_dic/core/shared/enums/entry_point.dart';
import 'package:my_dic/core/shared/enums/ui/tab.dart';
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

  String _getFormerName(){
    switch(_entryPoint){
      case EntryPoint.search:
        return RouteNames.search;
      case EntryPoint.studyRanking:
        return RouteNames.study;
      case EntryPoint.studyQuiz:
        return RouteNames.study;
      case EntryPoint.myword:
        return RouteNames.myWord;
      case EntryPoint.profile:
        return RouteNames.profile;
    }
  }

  // Search → WordDetail
  void toWordDetail(WordPageInput input) {
    _router.pushNamed('${_getFormerName()}-${RouteNames.wordDetail}', extra: input);
  }

  // Search → FlashCard
  void toFlashCard(QuizGameFragmentInput input) {
    _router.pushNamed('${_getFormerName()}-${RouteNames.flashCard}', extra: input);
  }


  // 戻る
  void pop() {
    _router.pop();
  }
}