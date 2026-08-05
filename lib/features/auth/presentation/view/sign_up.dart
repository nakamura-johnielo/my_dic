import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:my_dic/core/application/auth_lifecycle/auth_lifecycle_controller.dart';
import 'package:my_dic/core/application/auth_lifecycle/auth_lifecycle_provider.dart';
import 'package:my_dic/core/application/auth_lifecycle/auth_lifecycle_state.dart';
import 'package:my_dic/features/auth/di/view_model_di.dart';

class EmailPasswordPage extends ConsumerStatefulWidget {
  const EmailPasswordPage({super.key});

  @override
  ConsumerState<EmailPasswordPage> createState() => _EmailPasswordPageState();
}

class _EmailPasswordPageState extends ConsumerState<EmailPasswordPage> {
  final emailCtrl = TextEditingController();
  final passCtrl = TextEditingController();
  String? _localMessage;

  @override
  void dispose() {
    emailCtrl.dispose();
    passCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final lifecycle = ref.watch(authLifecycleProvider);
    final controller = ref.read(authLifecycleProvider.notifier);

    return Scaffold(
      appBar: AppBar(title: const Text('Email / Password Auth')),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: switch (lifecycle.phase) {
            AuthLifecyclePhase.initializing => const _CenteredProgress(
                label: '認証状態を確認しています…',
              ),
            AuthLifecyclePhase.creatingAccount => const _CenteredProgress(
                label: 'アカウントを作成しています…',
              ),
            AuthLifecyclePhase.signingIn => const _CenteredProgress(
                label: 'ログインしています…',
              ),
            AuthLifecyclePhase.provisioningProfile => const _CenteredProgress(
                label: 'プロフィールを準備しています…',
              ),
            AuthLifecyclePhase.signingOut => const _CenteredProgress(
                label: 'ログアウトしています…',
              ),
            AuthLifecyclePhase.emailUnverified ||
            AuthLifecyclePhase.verificationEmailFailed ||
            AuthLifecyclePhase.sendingVerificationEmail ||
            AuthLifecyclePhase.reloadingIdentity =>
              _buildVerificationPanel(lifecycle, controller),
            AuthLifecyclePhase.profileProvisioningFailed =>
              _buildProfileFailurePanel(lifecycle, controller),
            AuthLifecyclePhase.ready => const _CenteredProgress(
                label: 'プロフィールを表示します…',
              ),
            AuthLifecyclePhase.signedOut =>
              _buildAuthenticationForm(lifecycle, controller),
          },
        ),
      ),
    );
  }

  Widget _buildAuthenticationForm(
    AuthLifecycleState lifecycle,
    AuthLifecycleController controller,
  ) {
    final message = _localMessage ?? lifecycle.error?.message;
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
          onPressed: () async {
            final email = emailCtrl.text.trim();
            if (email.isEmpty) {
              setState(() => _localMessage = 'メールを入力してください');
              return;
            }
            final message = await ref
                .read(signInViewModelProvider.notifier)
                .resetEmailPassword(email);
            if (mounted) setState(() => _localMessage = message);
          },
          child: const Text('Forgot password?'),
        ),
      ],
    );
  }

  Widget _buildVerificationPanel(
    AuthLifecycleState lifecycle,
    AuthLifecycleController controller,
  ) {
    final waiting =
        lifecycle.phase == AuthLifecyclePhase.sendingVerificationEmail ||
            lifecycle.phase == AuthLifecyclePhase.reloadingIdentity;
    final deliveryFailed =
        lifecycle.phase == AuthLifecyclePhase.verificationEmailFailed;
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
            lifecycle.error!.message,
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
    AuthLifecycleState lifecycle,
    AuthLifecycleController controller,
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
            lifecycle.error!.message,
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
