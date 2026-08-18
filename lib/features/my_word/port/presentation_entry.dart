import 'package:flutter/material.dart';
import 'package:my_dic/core/session/session_scope_key.dart';
import 'package:my_dic/features/my_word/internal/presentation/view/my_word_fragment.dart';
import 'package:my_dic/features/my_word/port/composition.dart';

/// Controlled app entry: the app supplies the active session identity and
/// already assembled ports; presentation owns only its Riverpod state.
final class MyWordPresentationPage extends StatelessWidget {
  const MyWordPresentationPage({
    super.key,
    required this.scope,
    required this.ports,
  });

  final SessionScopeKey scope;
  final MyWordPorts ports;

  @override
  Widget build(BuildContext context) =>
      MyWordFragment(scope: scope, ports: ports);
}
