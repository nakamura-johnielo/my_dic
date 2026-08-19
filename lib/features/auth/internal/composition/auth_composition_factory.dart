import 'package:my_dic/features/auth/internal/application/auth_application_service.dart';
import 'package:my_dic/features/auth/internal/infrastructure/firebase/auth_repository.dart';
import 'package:my_dic/features/auth/port/composition_contract.dart';

/// 所有者専用のAuthアプリケーショングラフ構成。
AuthPorts createInternalAuthPorts({
  required AuthRuntimeGateway runtimeGateway,
}) {
  final repository = AuthRepository(runtimeGateway);
  final service = AuthApplicationService(repository);
  return AuthPorts(query: service, commands: service);
}
