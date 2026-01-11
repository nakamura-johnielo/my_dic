import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:my_dic/core/presentation/components/icons/rotating_icon.dart';
import 'package:my_dic/core/shared/enums/ui/button_status.dart';
import 'package:my_dic/core/shared/enums/ui/tab.dart';
import 'package:my_dic/features/auth/di/view_model_di.dart';

class EmailPasswordPage extends ConsumerStatefulWidget {
  const EmailPasswordPage({super.key});

  @override
  ConsumerState<EmailPasswordPage> createState() => _EmailPasswordPageState();
}

class _EmailPasswordPageState extends ConsumerState<EmailPasswordPage> {
  //final auth = FirebaseAuth.instance;
  final emailCtrl = TextEditingController();
  final passCtrl = TextEditingController();
  final IconData waitingIcon = Icons.refresh;
  //bool loading = false;
  String? message;

  bool _isActive(ButtonStatus status) {
    return status == ButtonStatus.normal || status == ButtonStatus.error;
  }

  Widget _iconBuilder(ButtonStatus status, IconData defaultIcon) {
    if (status == ButtonStatus.waiting) {
      return RotatingIcon(icon: waitingIcon);
    } else {
      return Icon(defaultIcon);
    }
  }

  Future<void> _handleAuth(
    Future<String> Function() action,
  ) async {
    setState(() {
      //loading = true;
      message = null;
    });
    try {
      message = await action();
      //final user = cred.user;
      if (!mounted) return;
      context.replace('/${MetaScreenTab.profile}/${MetaScreenPage.unAuthorized}');
      return; // 以降のsetStateを避ける
    } on FirebaseAuthException catch (e) {
      message = e.message;
    } finally {
      // if (mounted) {
      //   //setState(() => loading = false);
      // }
    }
  }

  // Future<void> _ensureUserDoc(User user) async {
  //   final docRef = FirebaseFirestore.instance.collection('users').doc(user.uid);
  //   final snap = await docRef.get();
  //   if (!snap.exists) {
  //     await docRef.set({
  //       'username': user.displayName ?? '',
  //       'email': user.email,
  //       'updatedAt': FieldValue.serverTimestamp(),
  //     });
  //   } else {
  //     // email が変わった等の同期
  //     await docRef.set({
  //       'email': user.email,
  //       'updatedAt': FieldValue.serverTimestamp(),
  //     }, SetOptions(merge: true));
  //   }
  // }

  @override
  void dispose() {
    emailCtrl.dispose();
    passCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final authNotifier = ref.read(signInViewModelProvider.notifier);
    final authViewModel = ref.watch(signInViewModelProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Email / Password Auth')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
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
            const SizedBox(height: 24),
            if (message != null)
              Text(message!, style: const TextStyle(color: Colors.red)),
            const Spacer(),
            ElevatedButton.icon(
              onPressed: _isActive(authViewModel.isWaitingSignUp)
                  ?  () {
                      if (!_validInputs()) return;
                      _handleAuth(() async {
                        await authNotifier.signUp(
                          emailCtrl.text.trim(),
                          passCtrl.text.trim(),
                        );
                        return '登録に成功しました。確認メールを送信しました。';
                      });
                      ;
                    }
                  :null,
              icon:
                  _iconBuilder(authViewModel.isWaitingSignUp, Icons.person_add),
              label: const Text('Sign Up'),
            ),
            const SizedBox(height: 8),
            OutlinedButton.icon(
              onPressed: _isActive(authViewModel.isWaitingSignIn)
                  ? () {
                      if (!_validInputs()) return;
                      _handleAuth(() => authNotifier.signIn(
                            emailCtrl.text.trim(),
                            passCtrl.text.trim(),
                          ));
                    }:null,
              icon: _iconBuilder(authViewModel.isWaitingSignIn, Icons.login),
              label: const Text('Sign In'),
            ),
            const SizedBox(height: 16),
            TextButton(
              onPressed: _isActive(authViewModel.isWaitingResetPassword)
                  ? () async {
                      final email = emailCtrl.text.trim();
                      if (email.isEmpty) {
                        setState(() => message = 'メールを入力してください');
                        return;
                      }
                      try {
                        await authNotifier.resetEmailPassword(email);
                        setState(() => message = 'リセットメールを送信しました');
                      } on FirebaseAuthException catch (e) {
                        setState(() => message = e.message);
                      }
                    }:null,
              child: const Text('Forgot password?'),
            ),
            const SizedBox(height: 12),
            TextButton.icon(
              onPressed: _isActive(authViewModel.isWaitingSignOut)
                  ? () async {
                      try {
                        await authNotifier.signOut();
                        setState(() => message = 'ログアウトしました');
                      } on FirebaseAuthException catch (e) {
                        setState(() => message = e.message);
                      }
                    }:null,
              icon: _iconBuilder(authViewModel.isWaitingSignOut, Icons.logout),
              label: const Text('Sign Out'),
            ),
          ],
        ),
      ),
    );
  }

  bool _validInputs() {
    final email = emailCtrl.text.trim();
    final pass = passCtrl.text.trim();
    if (!email.contains('@')) {
      setState(() => message = 'メールアドレスを確認してください');
      return false;
    }
    if (pass.length < 6) {
      setState(() => message = 'パスワードは6文字以上で入力');
      return false;
    }
    return true;
  }
}
