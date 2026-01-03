// プロフィールページ（UID/Email/ユーザーネーム表示、ユーザーネーム編集可）
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:my_dic/core/presentation/components/icons/rotating_icon.dart';
import 'package:my_dic/core/shared/enums/ui/button_status.dart';
import 'package:my_dic/core/shared/enums/ui/tab.dart';
import 'package:my_dic/features/user/di/service.dart';
import 'package:my_dic/features/user/di/viewmodel.dart';

class ProfilePage extends ConsumerStatefulWidget {
  const ProfilePage({super.key, required this.uid});
  final String uid;

  @override
  ConsumerState<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends ConsumerState<ProfilePage> {
  final _nameCtrl = TextEditingController();
  bool _saving = false;
  String? _msg;

  @override
  void dispose() {
    _nameCtrl.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    final name = _nameCtrl.text.trim();
    setState(() {
      _saving = true;
      _msg = null;
    });

    final message =
        await ref.read(userViewModelProvider.notifier).save(username: name);

    if (mounted) {
      setState(() {
        _msg = message;
        _saving = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(appUserStoreProvider);
    final userNotifier = ref.read(userViewModelProvider.notifier);
    final userUiViewModel = ref.watch(userViewModelProvider);

    if (user != null && _nameCtrl.text != user.username) {
      _nameCtrl.text = user.username;
    }

    return Scaffold(
        appBar: AppBar(
          title: const Text('Profile'),
          actions: [
            IconButton(
              icon: const Icon(Icons.logout),
              onPressed: () async {
                await userNotifier.signOut();
                if (!mounted) return;
                context.replace(
                    '/${ScreenTab.profile}/${ScreenPage.unAuthorized}');
              },
            )
          ],
        ),
        body: (user == null)
            ? const Center(child: Text('No user data available.'))
            : Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SelectableText('User ID: ${user.accountId}'),
                    const SizedBox(height: 8),
                    SelectableText('Email: ${user.email}'),
                    const SizedBox(height: 16),
                    const Text('Username'),
                    const SizedBox(height: 4),
                    TextField(
                      controller: _nameCtrl,
                      decoration: const InputDecoration(
                        border: OutlineInputBorder(),
                        hintText: 'ユーザーネームを入力',
                      ),
                    ),
                    const SizedBox(height: 12),
                    if (_msg != null)
                      Text(_msg!, style: const TextStyle(color: Colors.red)),
                    const Spacer(),
                    FilledButton.icon(
                      onPressed: _saving ? null : _save,
                      icon: userUiViewModel.savingButtonStatus ==
                              ButtonStatus.waiting
                          ? RotatingIcon(icon: Icons.refresh)
                          : const Icon(Icons.save),
                      label: _saving
                          ? const Text('Saving...')
                          : const Text('Save'),
                    ),
                  ],
                ),
              ));
  }
}
