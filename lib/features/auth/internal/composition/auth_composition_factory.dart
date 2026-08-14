import 'package:my_dic/features/auth/internal/application/auth_application_service.dart';
import 'package:my_dic/features/auth/internal/infrastructure/firebase/auth_repository.dart';
import 'package:my_dic/features/auth/port/composition_contract.dart';

/// Owner-only assembly of Auth's application graph.
AuthPorts createInternalAuthPorts({
  required AuthRuntimeGateway runtimeGateway,
}) {
  final repository = AuthRepository(runtimeGateway);
  final service = AuthApplicationService(repository);
  return AuthPorts(query: service, commands: service);
}
