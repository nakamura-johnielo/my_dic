// プロフィールページ（UID/Email/ユーザーネーム表示、ユーザーネーム編集可）
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:my_dic/app/session/app_session.dart';
import 'package:my_dic/app/session/session_providers.dart';
import 'package:my_dic/core/presentation/components/icons/rotating_icon.dart';
import 'package:my_dic/core/presentation/error/app_error_message.dart';
import 'package:my_dic/core/presentation/state/ui_effect.dart';
import 'package:my_dic/features/user/di/viewmodel.dart';
import 'package:my_dic/features/user/presentation/model/user_profile_ui_model.dart';

class ProfilePage extends ConsumerStatefulWidget {
  const ProfilePage({super.key, required this.uid});
  final String uid;

  @override
  ConsumerState<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends ConsumerState<ProfilePage> {
  final _nameCtrl = TextEditingController();
  late final ProviderSubscription<UserProfileUIState> _commandSubscription;

  @override
  void initState() {
    super.initState();
    _commandSubscription = ref.listenManual(
      userProfileViewModelProvider,
      (_, next) => _handleEffect(next),
    );
  }

  @override
  void dispose() {
    _commandSubscription.close();
    _nameCtrl.dispose();
    super.dispose();
  }

  void _handleEffect(UserProfileUIState next) {
    final envelope = next.pendingEffect;
    if (envelope == null) return;
    if (mounted && envelope.effect is UiNoticeEffect) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text((envelope.effect as UiNoticeEffect).message)),
      );
    }
    ref.read(userProfileViewModelProvider.notifier).consumeEffect(envelope.id);
  }

  void _save() {
    final name = _nameCtrl.text.trim();
    ref.read(userProfileViewModelProvider.notifier).save(username: name);
  }

  @override
  Widget build(BuildContext context) {
    final session = ref.watch(appSessionProvider);
    final viewModel = ref.watch(userProfileViewModelProvider);
    final isSubmitting = viewModel.command.isSubmitting;
    final ready = session is AppSessionReady ? session : null;
    final user = ready?.profile;

    if (user != null && _nameCtrl.text != user.username) {
      _nameCtrl.text = user.username;
    }

    return Scaffold(
        appBar: AppBar(
          title: const Text('Profile'),
          actions: [
            IconButton(
              icon: const Icon(Icons.logout),
              onPressed: isSubmitting
                  ? null
                  : () =>
                      ref.read(userProfileViewModelProvider.notifier).signOut(),
            )
          ],
        ),
        body: session is AppSessionLoadingProfile
            ? const Center(child: CircularProgressIndicator())
            : session is AppSessionFailure
                ? Center(child: Text(AppErrorMessage.from(session.error).text))
                : user == null
                    ? const Center(child: Text('No user data available.'))
                    : Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            SelectableText(
                                'User ID: ${ready!.identity.accountId}'),
                            const SizedBox(height: 8),
                            SelectableText(
                                'Email: ${ready.identity.email ?? user.email}'),
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
                            const Spacer(),
                            FilledButton.icon(
                              onPressed: isSubmitting ? null : _save,
                              icon: isSubmitting
                                  ? RotatingIcon(icon: Icons.refresh)
                                  : const Icon(Icons.save),
                              label: isSubmitting
                                  ? const Text('Saving...')
                                  : const Text('Save'),
                            ),
                          ],
                        ),
                      ));
  }
}
