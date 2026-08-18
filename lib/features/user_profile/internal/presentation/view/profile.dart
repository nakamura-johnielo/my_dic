// プロフィールページ（UID/Email/ユーザーネーム表示、ユーザーネーム編集可）
import 'package:flutter/material.dart';
import 'package:my_dic/core/session/session_scope_key.dart';
import 'package:my_dic/core/presentation/components/icons/rotating_icon.dart';
import 'package:my_dic/core/presentation/error/app_error_message.dart';
import 'package:my_dic/core/presentation/state/ui_effect.dart';
import 'package:my_dic/features/user_profile/internal/presentation/model/user_profile_ui_model.dart';
import 'package:my_dic/features/user_profile/internal/presentation/view_model/user_profile_view_model.dart';
import 'package:my_dic/features/user_profile/port/user_profile.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({
    super.key,
    required this.scope,
    required this.profile,
    required this.accountId,
    required this.email,
    required this.error,
    required this.isLoading,
    required this.updateUserProfile,
    required this.onSignOut,
  });
  final SessionScopeKey? scope;
  final AppUser? profile;
  final String? accountId;
  final String? email;
  final AppError? error;
  final bool isLoading;
  final UserProfileCommandPort updateUserProfile;
  final VoidCallback onSignOut;

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final _nameCtrl = TextEditingController();
  UserProfileViewModel? _viewModel;
  UserProfileUIState _viewState = const UserProfileUIState();
  VoidCallback? _removeViewModelListener;
  @override
  void dispose() {
    _removeViewModelListener?.call();
    _viewModel?.dispose();
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
    _viewModel?.consumeEffect(envelope.id);
  }

  void _save(AppUser user, SessionScopeKey scope) {
    final name = _nameCtrl.text.trim();
    _viewModel?.save(user, username: name);
  }

  UserProfileViewModel? _viewModelFor(SessionScopeKey? scope) {
    if (scope == null) return null;
    final current = _viewModel;
    if (current != null && current.scope == scope) return current;
    _removeViewModelListener?.call();
    current?.dispose();
    final viewModel = UserProfileViewModel(scope, widget.updateUserProfile);
    void listener(UserProfileUIState state) {
      if (!mounted) return;
      setState(() => _viewState = state);
      _handleEffect(state);
    }

    _removeViewModelListener = viewModel.addListener(listener);
    _viewModel = viewModel;
    return viewModel;
  }

  @override
  Widget build(BuildContext context) {
    final activeScope = widget.scope;
    _viewModelFor(activeScope);
    final viewModel = _viewState;
    final isSubmitting = viewModel.command.isSubmitting;
    final user = widget.profile;

    if (user != null && _nameCtrl.text != user.username) {
      _nameCtrl.text = user.username;
    }

    return Scaffold(
        appBar: AppBar(
          title: const Text('Profile'),
          actions: [
            IconButton(
              icon: const Icon(Icons.logout),
              onPressed: isSubmitting ? null : widget.onSignOut,
            )
          ],
        ),
        body: widget.isLoading
            ? const Center(child: CircularProgressIndicator())
            : widget.error != null
                ? Center(child: Text(AppErrorMessage.from(widget.error!).text))
                : user == null
                    ? const Center(child: Text('No user data available.'))
                    : Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            SelectableText('User ID: ${widget.accountId}'),
                            const SizedBox(height: 8),
                            SelectableText(
                                'Email: ${widget.email ?? user.email}'),
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
                              onPressed: isSubmitting || activeScope == null
                                  ? null
                                  : () => _save(user, activeScope),
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
