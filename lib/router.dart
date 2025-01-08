import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:my_dic/_View/search_fragment.dart';
import 'package:my_dic/_View/word_page_fragment.dart';

final goRouter = GoRouter(
  // アプリが起動した時
  initialLocation: '/',
  // パスと画面の組み合わせ
  routes: [
    GoRoute(
      path: '/',
      name: 'initial',
      pageBuilder: (context, state) {
        return MaterialPage(
          key: state.pageKey,
          child: SearchFragment(),
        );
      },
    ),
    // ex) アカウント画面
    GoRoute(
      path: '/wordpage',
      name: 'wordpage',
      pageBuilder: (context, state) {
        return MaterialPage(
          key: state.pageKey,
          child: const WordPageFragment(),
        );
      },
    ),
  ],

  // 遷移ページがないなどのエラーが発生した時に、このページに行く
  errorPageBuilder: (context, state) => MaterialPage(
    key: state.pageKey,
    child: Scaffold(
      body: Center(
        child: Text(state.error.toString()),
      ),
    ),
  ),
);
