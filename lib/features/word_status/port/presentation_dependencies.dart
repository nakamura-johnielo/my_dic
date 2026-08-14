import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:my_dic/features/word_status/port/composition_contract.dart';

/// App composition supplies the completed WordStatus capability to the
/// compatibility entry while consumers migrate to explicit constructor input.
final wordStatusPortsDependencyProvider = Provider<WordStatusPorts>(
  (_) => throw StateError('WordStatusPorts dependency was not supplied.'),
);
