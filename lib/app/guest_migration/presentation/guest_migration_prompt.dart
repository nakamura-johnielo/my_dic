import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:my_dic/app/bootstrap/guest_migration_composition.dart';
import 'package:my_dic/app/guest_migration/guest_data_summary.dart';
import 'package:my_dic/app/guest_migration/migrate_guest_data_usecase.dart';
import 'package:my_dic/app/guest_migration/presentation/guest_data_migration_dialog.dart';
import 'package:my_dic/app/routing/router.dart';
import 'package:my_dic/app/session/app_session.dart';
import 'package:my_dic/app/session/session_providers.dart';
import 'package:my_dic/core/session/session_scope_key.dart';
import 'package:my_dic/core/session/session_scope_provider.dart';
import 'package:my_dic/features/sync/port/sync.dart';

/// アカウント/エポックが所有するゲストデータ確認。処理は意図的に直列化しますが、検出または
/// 移行の実行中に新しいセッションを記憶し、次に実行します（最新優先）。
class GuestMigrationPrompt extends ConsumerStatefulWidget {
  const GuestMigrationPrompt({super.key});

  @override
  ConsumerState<GuestMigrationPrompt> createState() =>
      _GuestMigrationPromptState();
}

class _GuestMigrationPromptState extends ConsumerState<GuestMigrationPrompt> {
  bool _checking = false;
  int _generation = 0;
  SessionScopeKey? _pendingScope;
  SessionScopeKey? _dialogScope;

  @override
  void initState() {
    super.initState();
    ref.listenManual<AppSession>(appSessionProvider, (_, next) {
      final scope = ref.read(sessionScopeKeyProvider);
      if (next is AppSessionReady &&
          scope != null &&
          scope.accountScope == next.identity.accountId) {
        _request(scope);
      } else {
        _invalidateForSessionChange();
      }
    }, fireImmediately: true);
  }

  @override
  Widget build(BuildContext context) => const SizedBox.shrink();

  void _request(SessionScopeKey scope) {
    _pendingScope = scope;
    if (!_checking) _drain();
  }

  void _invalidateForSessionChange() {
    _generation++;
    _pendingScope = null;
    if (_dialogScope != null) {
      ref.read(rootNavigatorKeyProvider).currentState?.pop(false);
      _dialogScope = null;
    }
  }

  Future<void> _drain() async {
    if (_checking || !mounted) return;
    _checking = true;
    try {
      while (mounted && _pendingScope != null) {
        final scope = _pendingScope!;
        _pendingScope = null;
        final generation = _generation;
        await _run(scope, generation);
      }
    } finally {
      _checking = false;
      // 最後のループ条件とクリーンアップの間にReadyイベントが到着している場合があります。
      // グローバルな直列ゲートの後ろに取り残してはいけません。
      if (mounted && _pendingScope != null) _drain();
    }
  }

  bool _isCurrent(SessionScopeKey scope, int generation) =>
      mounted &&
      generation == _generation &&
      ref.read(sessionScopeKeyProvider) == scope &&
      ref.read(guestMigrationWorkflowDependenciesProvider).isCurrent(scope);

  Future<void> _run(SessionScopeKey scope, int generation) async {
    GuestDataSummary summary;
    try {
      summary =
          await ref.read(guestMigrationWorkflowDependenciesProvider).detect();
    } catch (_) {
      if (_isCurrent(scope, generation)) {
        _notice('Could not check guest data.', onRetry: () => _request(scope));
      }
      return;
    }
    if (!_isCurrent(scope, generation) || summary.isEmpty) return;

    final context = ref.read(rootNavigatorKeyProvider).currentContext;
    if (context == null || !context.mounted) return;
    _dialogScope = scope;
    final approved = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (_) => GuestDataMigrationDialog(summary: summary),
    );
    _dialogScope = null;
    if (approved != true || !_isCurrent(scope, generation)) return;

    try {
      await ref
          .read(guestMigrationWorkflowDependenciesProvider)
          .migrate(scope.accountScope, scope.epoch);
    } on GuestMigrationSessionChanged {
      // 最新セッションはすでにキュー済みか、そのセッションリスナーがキューに追加します。
      // 以前のアカウントへ通知してはいけません。
      return;
    } catch (_) {
      if (_isCurrent(scope, generation)) {
        _notice('Could not migrate guest data.',
            onRetry: () => _request(scope));
      }
      return;
    }
    if (!_isCurrent(scope, generation)) return;
    await _postMigrationSync(scope, generation);
  }

  Future<void> _postMigrationSync(SessionScopeKey scope, int generation) async {
    SyncRunOutcome outcome;
    try {
      outcome = await ref
          .read(guestMigrationWorkflowDependenciesProvider)
          .sync(SyncContext(
            accountId: scope.accountScope,
            sessionEpoch: scope.epoch,
            reason: 'post_guest_migration',
            cancellation: CancellationToken(),
          ));
    } catch (_) {
      if (_isCurrent(scope, generation)) {
        _notice('Migration completed, but sync could not be started.',
            onRetry: () => _postMigrationSync(scope, generation));
      }
      return;
    }
    if (!_isCurrent(scope, generation)) return;
    switch (outcome) {
      case SyncRunOutcome.success:
        return;
      case SyncRunOutcome.retryScheduled:
        _notice('Migration completed. Sync will retry automatically.');
      case SyncRunOutcome.nonRetryableFailure:
        _notice('Migration completed, but sync needs attention.',
            onRetry: () => _postMigrationSync(scope, generation));
      case SyncRunOutcome.cancelled:
        // セッションのキャンセルは通知しません。新しいReadyスコープがあれば、すでに
        // 最新優先キューを通じて保留されています。
        return;
    }
  }

  void _notice(String message, {VoidCallback? onRetry}) {
    if (!mounted) return;
    final context = ref.read(rootNavigatorKeyProvider).currentContext;
    if (context == null || !context.mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(message),
      action: onRetry == null
          ? null
          : SnackBarAction(label: 'Retry', onPressed: onRetry),
    ));
  }
}
