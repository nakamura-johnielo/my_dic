//word詳細画面
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:my_dic/core/shared/consts/ui/tab.dart';
import 'package:my_dic/features/word_page/presentation/view/word_page_fragment.dart';
import 'package:my_dic/router/route_names.dart';
import 'package:my_dic/router/study.dart';

GoRoute wordDetailRoute(String parentPath,String name,GlobalKey<NavigatorState>? key) => GoRoute(
      path: '$parentPath/${RoutePaths.wordDetail}',
      name: name,
      //parentNavigatorKey: key,
      pageBuilder: (context, state) {
        final input = state.extra as WordPageInput;
        return MaterialPage(child: WordPageFragment(input: input));
      },
      // routes: [
      //   quizRoute
      // ]
    );
