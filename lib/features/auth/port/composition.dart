import 'package:my_dic/features/auth/internal/composition/auth_composition_factory.dart';

import 'composition_contract.dart';

export 'composition_contract.dart';

/// Authが必要とするアプリケーション所有のランタイム依存関係。
final class AuthDependencies {
  const AuthDependencies({required this.runtimeGateway});

  final AuthRuntimeGateway runtimeGateway;
}

/// 明示的に型付けされた依存関係から、完成したAuth機能群を構築します。
AuthPorts createAuthPorts({required AuthDependencies dependencies}) =>
    createInternalAuthPorts(runtimeGateway: dependencies.runtimeGateway);
