import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:my_dic/app/guest_migration/presentation/guest_migration_prompt.dart';
import 'package:my_dic/app/routing/router.dart';
import 'package:my_dic/core/presentation/theme/color_scheme.dart';
import 'package:my_dic/core/section/db_loading/db_loader_overlay.dart';
import 'package:my_dic/core/shared/consts/enviroment.dart';

class MyApp extends ConsumerWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final goRouter = ref.watch(routerProvider);
    return MaterialApp.router(
      routerConfig: goRouter,
      debugShowCheckedModeBanner: false,
      title: APP_NAME,
      theme: ThemeData(
        colorScheme: darkColorScheme,
        useMaterial3: true,
        bottomNavigationBarTheme: BottomNavigationBarThemeData(
          backgroundColor: Theme.of(context).colorScheme.surfaceDim,
          unselectedItemColor: Theme.of(context).colorScheme.onSurfaceVariant,
        ),
      ),
      builder: (context, child) => Stack(
        children: [
          child ?? const SizedBox.shrink(),
          const DatabaseLoadingOverlay(),
          const GuestMigrationPrompt(),
        ],
      ),
    );
  }
}
