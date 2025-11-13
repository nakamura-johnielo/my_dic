import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:my_dic/Constants/enviroment.dart';
import 'package:my_dic/DI/product.dart';
import 'package:my_dic/_Framework_Driver/Database/drift/database_provider.dart';
//import 'package:my_dic/_View/main_activity.dart';
import 'package:my_dic/router.dart';

// 1. エントリーポイントのmain関数
void main() async {
  //dbのクロースのためのライフサイクル監視
  //AppLifecycleManager内でdbproviderインスタンス化済み
  WidgetsFlutterBinding.ensureInitialized();
  //WidgetsBinding.instance.addObserver(AppLifecycleManager());

  //DI注入
  setupLocator();

  //DBチェック、アクティブ化
  // 起動時にDBをオープンしてマイグレーションを実行
  await DI<DatabaseProvider>().customSelect('SELECT 1').get();

  runApp(const ProviderScope(child: MyApp()));
  //runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      routerConfig: goRouter,
      /* routerDelegate: goRouter.routerDelegate,
      routeInformationParser: goRouter.routeInformationParser,
      routeInformationProvider: goRouter.routeInformationProvider, */

      debugShowCheckedModeBanner: false, //debug banner非表示
      title: APP_NAME,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      //home: const MainActivity(),
    );
  }
}
