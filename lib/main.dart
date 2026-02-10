import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:my_dic/core/infrastructure/database/shared_preferences/shared_preferences.dart';
import 'package:my_dic/core/section/db_loading/db_loader_overlay.dart';
import 'package:my_dic/core/shared/consts/enviroment.dart';
import 'package:my_dic/core/application/effects/auth_effect_provider.dart';
import 'package:my_dic/core/presentation/theme/color_scheme.dart';
import 'package:my_dic/core/di/data/data_di.dart';
import 'package:my_dic/features/sync/di.dart';
import 'package:my_dic/router/router.dart';
import 'package:my_dic/firebase_options.dart';
import 'package:shared_preferences/shared_preferences.dart';

// 1. エントリーポイントのmain関数
void main() async {
  //dbのクロースのためのライフサイクル監視
  //AppLifecycleManager内でdbproviderインスタンス化済み
  WidgetsFlutterBinding.ensureInitialized();
  //WidgetsBinding.instance.addObserver(AppLifecycleManager());
  // Windowsの場合、少し待機してからFirebaseを初期化

  //DBチェック、アクティブ化
  // 起動時にDBをオープンしてマイグレーションを実行
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  // SharedPreferencesを事前初期化
  //TODO shapref inicialize
  // SharedPreferencesを事前初期化
  final sharedPreferences = await SharedPreferences.getInstance();

  runApp(ProviderScope(overrides: [
    sharedPreferencesProvider.overrideWithValue(sharedPreferences),
  ], child: MyApp()));
}

class MyApp extends ConsumerWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    //!TODO databseの初回読み込みちゃんとする！！
    ref.read(databaseProvider).customSelect('SELECT 1').get();

    ref.watch(authEffectProvider); //認証状態の変化を監視し副作用を実行 synconce
    ref.watch(autoSyncProvider); //自動同期開始

    final goRouter = ref.watch(routerProvider);

    return MaterialApp.router(
      routerConfig: goRouter,

      debugShowCheckedModeBanner: false, //debug banner非表示
      title: APP_NAME,
      theme: ThemeData(
        colorScheme: darkColorScheme,
        useMaterial3: true,
        bottomNavigationBarTheme: BottomNavigationBarThemeData(
          backgroundColor: Theme.of(context).colorScheme.surfaceDim,
          unselectedItemColor:
              Theme.of(context).colorScheme.onSurfaceVariant, //未選択時の色
        ),
      ),
      builder: (context, child) {
        return Stack(
          children: [
            child ?? const SizedBox.shrink(),
            // オーバーレイを常に表示
            const DatabaseLoadingOverlay(),
          ],
        );
      },
    );
  }
}
