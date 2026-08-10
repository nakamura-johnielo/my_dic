import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'session_scope_key.dart';

/// App-owned lifecycle composition overrides this dependency with the active
/// scope. Feature presentation only depends on this neutral session boundary.
final sessionScopeKeyProvider = Provider<SessionScopeKey?>((_) => null);
