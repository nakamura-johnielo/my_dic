import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:my_dic/core/presentation/state/ui_effect.dart';
import 'package:my_dic/core/session/session_scope_key.dart';
import 'package:my_dic/features/my_word/internal/presentation/provider/my_word_presentation_providers.dart';
import 'package:my_dic/features/my_word/internal/presentation/ui_model/my_word_ui_model.dart';
import 'package:my_dic/features/my_word/internal/presentation/view/my_word_fragment.dart';
import 'package:my_dic/features/my_word/internal/presentation/view_model/my_word_status_command.dart';
import 'package:my_dic/features/my_word/port/composition.dart';
import 'package:my_dic/features/word_status/port/presentation_entry.dart'
    as status;

/// Controlled app entry: the app supplies the active session identity and
/// already assembled ports; presentation owns only its Riverpod state.
class MyWordPresentationPage extends StatelessWidget {
  const MyWordPresentationPage(
      {super.key, required this.scope, required this.ports});

  final SessionScopeKey scope;
  final MyWordPorts ports;

  @override
  Widget build(BuildContext context) =>
      MyWordFragment(scope: scope, ports: ports);
}

/// The sole MyWord-to-WordStatus presentation bridge.
class MyWordStatusButtonsEntry extends ConsumerWidget {
  const MyWordStatusButtonsEntry(
      {super.key,
      required this.scope,
      required this.ports,
      required this.wordId});
  final SessionScopeKey? scope;
  final MyWordPorts? ports;
  final String wordId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (scope == null || ports == null)
      return const status.MyWordStatusButtons(
          viewModel: _DetachedMyWordStatusViewModel());
    final key = (scope: scope!, ports: ports!, wordId: wordId);
    ref.listen(myWordStatusCommandProvider(key), (previous, next) {
      final envelope = next.pendingEffect;
      if (envelope == null || previous?.pendingEffect?.id == envelope.id)
        return;
      ref
          .read(myWordStatusCommandProvider(key).notifier)
          .consumeEffect(envelope.id);
      if (envelope.effect case UiNoticeEffect(:final message)) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (context.mounted)
            ScaffoldMessenger.maybeOf(context)
                ?.showSnackBar(SnackBar(content: Text(message)));
        });
      }
    });
    final commandState = ref.watch(myWordStatusCommandProvider(key));
    return status.MyWordStatusButtons(
        viewModel: _MyWordStatusViewModel(
            item: ref.watch(myWordItemUiModelProvider(key)),
            command: ref.read(myWordStatusCommandProvider(key).notifier),
            commandState: commandState));
  }
}

class _MyWordStatusViewModel
    implements status.WordStatusViewModel, status.WordStatusCommandProgress {
  const _MyWordStatusViewModel(
      {required this.item, required this.command, required this.commandState});
  final AsyncValue<MyWordItemUiModel?> item;
  final MyWordStatusCommand command;
  final MyWordStatusCommandState commandState;
  @override
  bool get hasNote => false;
  @override
  bool get isLoading => item.isLoading;
  @override
  bool get isSubmitting => commandState.isSubmitting;
  @override
  String? get readError => item.whenOrNull(error: (error, _) => '$error');
  @override
  bool get isBookmarked => item.valueOrNull?.isBookmarked ?? false;
  @override
  bool get isLearned => item.valueOrNull?.isLearned ?? false;
  @override
  Future<void> toggleBookmark() => command.toggleBookmark(isBookmarked);
  @override
  Future<void> toggleHasNote() async {}
  @override
  Future<void> toggleLearned() => command.toggleLearned(isLearned);
}

class _DetachedMyWordStatusViewModel implements status.WordStatusViewModel {
  const _DetachedMyWordStatusViewModel();
  @override
  bool get hasNote => false;
  @override
  bool get isBookmarked => false;
  @override
  bool get isLearned => false;
  @override
  bool get isLoading => true;
  @override
  String? get readError => null;
  @override
  Future<void> toggleBookmark() async {}
  @override
  Future<void> toggleHasNote() async {}
  @override
  Future<void> toggleLearned() async {}
}
