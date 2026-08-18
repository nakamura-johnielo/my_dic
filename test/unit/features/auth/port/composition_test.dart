import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:my_dic/features/auth/port/auth.dart';
import 'package:my_dic/features/auth/port/composition.dart';

final class _RuntimeGateway extends Mock implements AuthRuntimeGateway {}

void main() {
  test('factory constructs completed ports from the required runtime gateway', () {
    final ports = createAuthPorts(
      dependencies: AuthDependencies(runtimeGateway: _RuntimeGateway()),
    );

    expect(ports.query, isA<AuthQueryPort>());
    expect(ports.commands, isA<AuthCommandPort>());
    expect(ports.query, same(ports.commands));
  });
}
