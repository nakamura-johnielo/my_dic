import 'package:flutter/material.dart';
import 'package:my_dic/app/app.dart';
import 'package:my_dic/app/bootstrap/bootstrap.dart';

// 1. エントリーポイントのmain関数
void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(AppBootstrap(appBuilder: () => const MyApp()));
}
