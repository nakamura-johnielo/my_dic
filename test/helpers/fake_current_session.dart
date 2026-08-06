import 'package:my_dic/app/session/current_session.dart';

/// Fake [CurrentSession] for tests, avoiding any Firebase/Auth Repository
/// dependency.
class FakeCurrentSession implements CurrentSession {
  FakeCurrentSession({this.accountIdOrNull});

  @override
  final String? accountIdOrNull;

  @override
  String requireAccountId() {
    final id = accountIdOrNull;
    if (id == null) throw SessionRequiresAccountError();
    return id;
  }
}
