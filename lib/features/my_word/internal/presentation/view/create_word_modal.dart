import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:my_dic/features/my_word/internal/presentation/provider/my_word_presentation_providers.dart';
import 'package:my_dic/features/my_word/internal/presentation/ui_model/my_word_event.dart';
import 'package:my_dic/core/presentation/state/ui_effect.dart';
import 'package:my_dic/core/session/session_scope_key.dart';
import 'package:my_dic/features/my_word/port/composition.dart';

class WordRegistrationModal extends ConsumerStatefulWidget {
  const WordRegistrationModal(
      {super.key, required this.scope, required this.ports, this.onRegistered});
  final SessionScopeKey scope;
  final MyWordPorts ports;

  final VoidCallback? onRegistered;

  @override
  ConsumerState<WordRegistrationModal> createState() =>
      _WordRegistrationModalState();
}

class _WordRegistrationModalState extends ConsumerState<WordRegistrationModal> {
  final _headwordController = TextEditingController();
  final _descriptionController = TextEditingController();
  late final ProviderSubscription<MyWordCommandState> _commandSubscription;

  @override
  void initState() {
    super.initState();
    _commandSubscription = ref.listenManual(
      myWordRegistrationCommandProvider(
          (scope: widget.scope, ports: widget.ports)),
      (_, next) => _handleEffect(next),
    );
  }

  @override
  void dispose() {
    _commandSubscription.close();
    _headwordController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  void _handleEffect(MyWordCommandState next) {
    final envelope = next.pendingEffect;
    if (envelope == null || !mounted) return;
    final command = ref.read(myWordRegistrationCommandProvider(
        (scope: widget.scope, ports: widget.ports)).notifier);
    if (envelope.effect is UiCloseDialogEffect &&
        next.command.operation == 'register') {
      widget.onRegistered?.call();
      Navigator.of(context).pop();
    } else if (envelope.effect is UiNoticeEffect) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text((envelope.effect as UiNoticeEffect).message)),
      );
    }
    command.consumeEffect(envelope.id);
  }

  @override
  Widget build(BuildContext context) {
    final key = (scope: widget.scope, ports: widget.ports);
    final commandState = ref.watch(myWordRegistrationCommandProvider(key));
    return FractionallySizedBox(
      heightFactor: .9,
      widthFactor: .8,
      child: Material(
        color: Theme.of(context).colorScheme.surfaceContainer,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(10)),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Register My Word',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 20),
              TextField(
                autofocus: true,
                controller: _headwordController,
                decoration: const InputDecoration(labelText: 'Headword'),
              ),
              const SizedBox(height: 26),
              TextField(
                minLines: 3,
                maxLines: null,
                controller: _descriptionController,
                decoration: const InputDecoration(
                  labelText: 'Description',
                  border: OutlineInputBorder(),
                ),
              ),
              const Spacer(),
              SizedBox(
                width: double.infinity,
                child: FilledButton(
                  onPressed: commandState.command.isSubmitting
                      ? null
                      : () => ref
                          .read(myWordRegistrationCommandProvider(key).notifier)
                          .registerWord(
                            headword: _headwordController.text,
                            description: _descriptionController.text,
                          ),
                  child: commandState.command.isSubmitting
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(),
                        )
                      : const Text('Register'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
