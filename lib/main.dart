import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:my_dic/Constants/enviroment.dart';
import 'package:my_dic/DI/product.dart';
import 'package:my_dic/core/application/app_effects/auth_effect_provider.dart';
import 'package:my_dic/_View/Themes/color_scheme.dart';
import 'package:my_dic/router.dart';
import 'package:my_dic/firebase_options.dart';

// 1. エントリーポイントのmain関数
void main() async {
  //dbのクロースのためのライフサイクル監視
  //AppLifecycleManager内でdbproviderインスタンス化済み
  WidgetsFlutterBinding.ensureInitialized();
  //WidgetsBinding.instance.addObserver(AppLifecycleManager());
  // Windowsの場合、少し待機してからFirebaseを初期化

  //DI注入
  //setupLocator();

  //DBチェック、アクティブ化
  // 起動時にDBをオープンしてマイグレーションを実行
  //await DI<DatabaseProvider>().customSelect('SELECT 1').get();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const ProviderScope(child: MyApp()));
  //runApp(const MyApp());
}

class MyApp extends ConsumerWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    //!TODO databseの初回読み込みちゃんとする！！
    ref.read(databaseProvider).customSelect('SELECT 1').get();

    ref.watch(authEffectProvider);
    final goRouter = ref.watch(routerProvider);

    return MaterialApp.router(
      routerConfig: goRouter,
      /* routerDelegate: goRouter.routerDelegate,
      routeInformationParser: goRouter.routeInformationParser,
      routeInformationProvider: goRouter.routeInformationProvider, */

      debugShowCheckedModeBanner: false, //debug banner非表示
      title: APP_NAME,
      theme: ThemeData(
        colorScheme: darkColorScheme,
        //colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
        // cardTheme: CardThemeData(
        //   color: Theme.of(context).colorScheme.surfaceContainer,
        // ),
        bottomNavigationBarTheme: BottomNavigationBarThemeData(
          backgroundColor: Theme.of(context).colorScheme.surfaceDim,
          unselectedItemColor:
              Theme.of(context).colorScheme.onSurfaceVariant, //未選択時の色
        ),
      ),
      //home: const MainActivity(),
    );
  }
}
