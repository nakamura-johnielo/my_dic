import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'session_scope_key.dart';

/// アプリ所有のライフサイクル構成が、この依存関係をアクティブなスコープで上書きします。
/// 機能のプレゼンテーションは、この中立的なセッション境界だけに依存します。
final sessionScopeKeyProvider = Provider<SessionScopeKey?>((_) => null);
