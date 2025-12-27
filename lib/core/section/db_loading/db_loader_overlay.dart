import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:my_dic/core/di/view_model/view_model.dart';
import 'package:my_dic/core/section/db_loading/database_loading_notifier.dart';
import 'package:my_dic/core/shared/enums/web/db.dart';

class DatabaseLoadingOverlay extends ConsumerWidget {
  const DatabaseLoadingOverlay({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final loadingState = ref.watch(databaseLoadingProvider);

    if (!loadingState.isLoading) {
      return const SizedBox.shrink();
    }

    Widget myIconBuilder(IconData active, IconData inactive, bool isActive) {
      return Icon(
        isActive ? active : inactive,
        size: isActive ? 48 : 32,
        color: isActive
            ? Theme.of(context).colorScheme.primary
            : Theme.of(context).colorScheme.onSurfaceVariant,
      );
    }

    return Material(
      color: Colors.black87,
      child: Center(
        child: Container(
          padding: const EdgeInsets.all(32),
          margin: const EdgeInsets.symmetric(horizontal: 40),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surface,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // パーセンテージ表示
              Row(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  myIconBuilder(Icons.looks_one, Icons.looks_one_outlined,
                      loadingState.loadingType == WebDBLoadingType.download),
                  myIconBuilder(
                      Icons.looks_two,
                      Icons.looks_two_outlined,
                      loadingState.loadingType ==
                          WebDBLoadingType.decompressed),
                  myIconBuilder(Icons.looks_3, Icons.looks_3_outlined,
                      loadingState.loadingType == WebDBLoadingType.parsing),
                  myIconBuilder(Icons.looks_4, Icons.looks_4_outlined,
                      loadingState.loadingType == WebDBLoadingType.import),
                ],
              ),
              SizedBox(height: 16),
              Text(
                loadingState.loadingType.name,
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).colorScheme.primary,
                    ),
              ),
              SizedBox(height: 16),
              Text(
                '${(loadingState.progress * 100).toStringAsFixed(0)}%',
                style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).colorScheme.primary,
                    ),
              ),
              const SizedBox(height: 24),

              // 進捗バー
              SizedBox(
                width: 300,
                child: LinearProgressIndicator(
                  value:
                      (loadingState.loadingType == WebDBLoadingType.download ||
                              loadingState.loadingType ==
                                  WebDBLoadingType.decompressed ||
                              loadingState.loadingType ==
                                  WebDBLoadingType.parsing)
                          ? null // インデターミネートモード
                          : loadingState.progress,
                  minHeight: 8,
                  backgroundColor: Theme.of(context).colorScheme.surfaceVariant,
                  valueColor: AlwaysStoppedAnimation<Color>(
                    Theme.of(context).colorScheme.primary,
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // メッセージ表示
              Text(
                loadingState.message,
                style: Theme.of(context).textTheme.bodyLarge,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                '初回起動時のみデータベースを準備しています\nしばらくお待ちください...',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
