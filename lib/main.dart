import 'package:flutter/material.dart';
import 'package:my_dic/DI/product.dart';
import 'package:my_dic/_View/main_activity.dart';

// 1. エントリーポイントのmain関数
void main() {
  //dbのクロースのためのライフサイクル監視
  //AppLifecycleManager内でdbproviderインスタンス化済み
  WidgetsFlutterBinding.ensureInitialized();
  //WidgetsBinding.instance.addObserver(AppLifecycleManager());

  //DI注入
  setupLocator();

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const MainActivity(title: 'Flutter Demo Home Page'),
    );
  }
}
