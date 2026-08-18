import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:my_dic/app/bootstrap/feature_composition/auth_composition.dart';
import 'package:my_dic/app/bootstrap/firebase_providers.dart';
import 'package:my_dic/features/auth/port/auth.dart';
import 'package:my_dic/features/auth/port/composition.dart';

final class _RuntimeGateway extends Mock implements AuthRuntimeGateway {}

final class _Query extends Mock implements AuthQueryPort {}

final class _Commands extends Mock implements AuthCommandPort {}

void main() {
  test('builds and refreshes completed Auth ports from the runtime override',
      () {
    final container = ProviderContainer(
      overrides: [
        firebaseAuthRuntimeProvider.overrideWithValue(_RuntimeGateway()),
      ],
    );
    addTearDown(container.dispose);

    final first = container.read(authPortsProvider);
    expect(container.read(authQueryPortProvider), same(first.query));
    expect(container.read(authCommandPortProvider), same(first.commands));
    expect(container.refresh(authPortsProvider), isNot(same(first)));
  });

  test('allows the completed capability to be overridden', () {
    final ports = AuthPorts(query: _Query(), commands: _Commands());
    final container = ProviderContainer(
      overrides: [authPortsProvider.overrideWithValue(ports)],
    );
    addTearDown(container.dispose);

    expect(container.read(authPortsProvider), same(ports));
    expect(container.read(authQueryPortProvider), same(ports.query));
    expect(container.read(authCommandPortProvider), same(ports.commands));
  });
}
