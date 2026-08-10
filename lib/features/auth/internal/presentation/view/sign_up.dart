import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:my_dic/core/presentation/error/app_error_message.dart';
import 'package:my_dic/core/presentation/state/ui_effect.dart';
import 'package:my_dic/features/auth/internal/di/view_model_di.dart';
import 'package:my_dic/features/auth/internal/presentation/ui_model/sign_in_model.dart';
import 'package:my_dic/features/auth/port/presentation_entry.dart';

class EmailPasswordPage extends ConsumerStatefulWidget {
  const EmailPasswordPage({super.key});

  @override
  ConsumerState<EmailPasswordPage> createState() => _EmailPasswordPageState();
}

class _EmailPasswordPageState extends ConsumerState<EmailPasswordPage> {
  final emailCtrl = TextEditingController();
  final passCtrl = TextEditingController();
  String? _localMessage;
  ProviderSubscription<SignInUIState>? _commandSubscription;

  @override
  void dispose() {
    _commandSubscription?.close();
    emailCtrl.dispose();
    passCtrl.dispose();
    super.dispose();
  }

  void _handleEffect(SignInUIState next) {
    final envelope = next.pendingEffect;
    if (envelope == null) return;
    if (mounted && envelope.effect is UiNoticeEffect) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text((envelope.effect as UiNoticeEffect).message)),
      );
    }
    ref.read(signInViewModelProvider.notifier).consumeEffect(envelope.id);
  }

  void _ensureCommandListener() {
    _commandSubscription ??= ref.listenManual(
      signInViewModelProvider,
      (_, next) => _handleEffect(next),
    );
  }

  @override
  Widget build(BuildContext context) {
    final lifecycle = ref.watch(authPresentationStateProvider);
    final controller = ref.read(authPresentationActionsProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Email / Password Auth')),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: switch (lifecycle.phase) {
            AuthPresentationPhase.initializing => const _CenteredProgress(
                label: '認証状態を確認しています…',
              ),
            AuthPresentationPhase.creatingAccount => const _CenteredProgress(
                label: 'アカウントを作成しています…',
              ),
            AuthPresentationPhase.signingIn => const _CenteredProgress(
                label: 'ログインしています…',
              ),
            AuthPresentationPhase.provisioningProfile => const _CenteredProgress(
                label: 'プロフィールを準備しています…',
              ),
            AuthPresentationPhase.signingOut => const _CenteredProgress(
                label: 'ログアウトしています…',
              ),
            AuthPresentationPhase.emailUnverified ||
            AuthPresentationPhase.verificationEmailFailed ||
            AuthPresentationPhase.sendingVerificationEmail ||
            AuthPresentationPhase.reloadingIdentity =>
              _buildVerificationPanel(lifecycle, controller),
            AuthPresentationPhase.profileProvisioningFailed =>
              _buildProfileFailurePanel(lifecycle, controller),
            AuthPresentationPhase.ready => const _CenteredProgress(
                label: 'プロフィールを表示します…',
              ),
            AuthPresentationPhase.signedOut =>
              _buildAuthenticationForm(lifecycle, controller),
          },
        ),
      ),
    );
  }

  Widget _buildAuthenticationForm(
    AuthPresentationState lifecycle,
    AuthPresentationActions controller,
  ) {
    final message = _localMessage ??
        (lifecycle.error == null
            ? null
            : AppErrorMessage.from(lifecycle.error!).text);
    return Column(
      children: [
        TextField(
          controller: emailCtrl,
          keyboardType: TextInputType.emailAddress,
          decoration: const InputDecoration(labelText: 'Email'),
        ),
        const SizedBox(height: 12),
        TextField(
          controller: passCtrl,
          obscureText: true,
          decoration: const InputDecoration(labelText: 'Password (6文字以上)'),
        ),
        if (message != null) ...[
          const SizedBox(height: 16),
          Text(message,
              style: TextStyle(color: Theme.of(context).colorScheme.error)),
        ],
        const Spacer(),
        FilledButton.icon(
          onPressed: () {
            if (!_validInputs()) return;
            setState(() => _localMessage = null);
            controller.signUp(emailCtrl.text.trim(), passCtrl.text.trim());
          },
          icon: const Icon(Icons.person_add),
          label: const Text('Sign Up'),
        ),
        const SizedBox(height: 8),
        OutlinedButton.icon(
          onPressed: () {
            if (!_validInputs()) return;
            setState(() => _localMessage = null);
            controller.signIn(emailCtrl.text.trim(), passCtrl.text.trim());
          },
          icon: const Icon(Icons.login),
          label: const Text('Sign In'),
        ),
        const SizedBox(height: 16),
        TextButton(
          onPressed: () {
            final email = emailCtrl.text.trim();
            if (email.isEmpty) {
              setState(() => _localMessage = 'メールを入力してください');
              return;
            }
            _ensureCommandListener();
            ref
                .read(signInViewModelProvider.notifier)
                .resetEmailPassword(email);
          },
          child: const Text('Forgot password?'),
        ),
      ],
    );
  }

  Widget _buildVerificationPanel(
    AuthPresentationState lifecycle,
    AuthPresentationActions controller,
  ) {
    final waiting =
        lifecycle.phase == AuthPresentationPhase.sendingVerificationEmail ||
            lifecycle.phase == AuthPresentationPhase.reloadingIdentity;
    final deliveryFailed =
        lifecycle.phase == AuthPresentationPhase.verificationEmailFailed;
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Icon(Icons.mark_email_unread_outlined, size: 64),
        const SizedBox(height: 16),
        Text(
          deliveryFailed
              ? 'アカウントは作成されましたが、確認メールを送信できませんでした。'
              : '${lifecycle.auth?.email ?? '登録したメールアドレス'}へ確認メールを送信しました。',
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 8),
        const Text(
          'メール内のリンクを開いた後、「確認済み」を押してください。',
          textAlign: TextAlign.center,
        ),
        if (lifecycle.notice != null) ...[
          const SizedBox(height: 16),
          Text(lifecycle.notice!, textAlign: TextAlign.center),
        ],
        if (lifecycle.error != null) ...[
          const SizedBox(height: 16),
          Text(
            AppErrorMessage.from(lifecycle.error!).text,
            textAlign: TextAlign.center,
            style: TextStyle(color: Theme.of(context).colorScheme.error),
          ),
        ],
        const SizedBox(height: 24),
        if (waiting) const CircularProgressIndicator(),
        if (!waiting) ...[
          FilledButton(
            onPressed: controller.checkEmailVerification,
            child: const Text('確認済み'),
          ),
          TextButton(
            onPressed: controller.resendVerificationEmail,
            child: const Text('確認メールを再送'),
          ),
          TextButton(
            onPressed: controller.signOut,
            child: const Text('ログアウト'),
          ),
        ],
      ],
    );
  }

  Widget _buildProfileFailurePanel(
    AuthPresentationState lifecycle,
    AuthPresentationActions controller,
  ) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Icon(Icons.cloud_off_outlined, size: 64),
        const SizedBox(height: 16),
        const Text('プロフィールの準備を完了できませんでした。'),
        if (lifecycle.error != null) ...[
          const SizedBox(height: 8),
          Text(
            AppErrorMessage.from(lifecycle.error!).text,
            textAlign: TextAlign.center,
            style: TextStyle(color: Theme.of(context).colorScheme.error),
          ),
        ],
        const SizedBox(height: 24),
        FilledButton(
          onPressed: controller.retryProfileProvisioning,
          child: const Text('再試行'),
        ),
        TextButton(
          onPressed: controller.signOut,
          child: const Text('ログアウト'),
        ),
      ],
    );
  }

  bool _validInputs() {
    final email = emailCtrl.text.trim();
    final pass = passCtrl.text.trim();
    if (!email.contains('@')) {
      setState(() => _localMessage = 'メールアドレスを確認してください');
      return false;
    }
    if (pass.length < 6) {
      setState(() => _localMessage = 'パスワードは6文字以上で入力してください');
      return false;
    }
    return true;
  }
}

class _CenteredProgress extends StatelessWidget {
  final String label;

  const _CenteredProgress({required this.label});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const CircularProgressIndicator(),
          const SizedBox(height: 16),
          Text(label),
        ],
      ),
    );
  }
}
