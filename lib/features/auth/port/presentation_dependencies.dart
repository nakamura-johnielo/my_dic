import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'command.dart';

/// Presentation-only dependency supplied by app bootstrap.
final authCommandPortDependencyProvider = Provider<AuthCommandPort>(
  (_) => throw StateError('AuthCommandPort presentation dependency missing.'),
);
