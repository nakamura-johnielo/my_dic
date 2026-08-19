import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:my_dic/app/bootstrap/session_composition.dart';
import 'package:my_dic/app/bootstrap/feature_composition/sync_composition.dart';
import 'package:my_dic/app/session/app_session.dart';
import 'package:my_dic/app/session/session_providers.dart';
import 'package:my_dic/core/session/session_scope_key.dart';
import 'package:my_dic/core/shared/utils/logger.dart';
import 'package:my_dic/features/sync/port/sync.dart';
import 'package:my_dic/integration/session_lifecycle_workflow/auth_lifecycle_effects.dart';

/// ウィジェットの再ビルドとは独立して、アプリケーション全体のエフェクトを管理します。
///
/// セッションの準備完了時およびアプリ再開時に、公開ワークフローの入口である
/// `syncRunnerProvider` を通じてSyncを実行します。
final applicationLifecycleEffectsProvider = Provider<void>((ref) {
  SessionScopeKey? lastSessionReadyScope;
  final observer = _ApplicationLifecycleObserver(
    onResumed: () => _triggerForegroundSync(
      ref,
      reason: 'app_resumed',
    ),
  );
  WidgetsBinding.instance.addObserver(observer);
  ref.onDispose(() {
    WidgetsBinding.instance.removeObserver(observer);
  });

  ref.watch(authLifecycleEffectProvider);
  ref.watch(sessionFenceEffectProvider);
  ref.read(syncRunnerProvider);

  ref.listen<AppSession>(appSessionProvider, (previous, next) {
    if (next is! AppSessionReady) return;
    final scope = ref.read(sessionScopeKeyProvider);
    // 準備完了のプロフィールは繰り返し通知される場合があります。安定したスコープの有効化
    // （ログイン、ゲストへのログアウト、ゲストからのログイン、アカウント切替）ごとに、
    // フォアグラウンドトリガーは1回だけ実行します。アプリ再開は別イベントです。
    if (scope == null || scope == lastSessionReadyScope) return;
    lastSessionReadyScope = scope;
    _triggerForegroundSync(ref, reason: 'session_ready');
  }, fireImmediately: true);
});

Future<void> _triggerForegroundSync(Ref ref, {required String reason}) async {
  final scope = ref.read(sessionScopeKeyProvider);
  if (scope == null) return;
  try {
    await ref.read(syncRunnerProvider).foreground(
          SyncContext(
            accountId: scope.accountScope,
            sessionEpoch: scope.epoch,
            reason: reason,
            cancellation: CancellationToken(),
          ),
        );
  } catch (_) {
    // Syncの結果はスケジューラーが報告します。予期しない例外の自由形式テキストを
    // アプリケーションログへ公開してはいけません。
    AppLogger.print('Foreground sync did not complete.');
  }
}

class _ApplicationLifecycleObserver with WidgetsBindingObserver {
  _ApplicationLifecycleObserver({required this.onResumed});

  final void Function() onResumed;

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) onResumed();
  }
}
