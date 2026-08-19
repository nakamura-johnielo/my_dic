import 'dart:collection';

import 'model/remote_mutation.dart';

/// 機能が所有し、すでにエンコード済みのリモートドキュメント計画です。
///
/// Sync の外部システム実行者は、データセット名、コレクション名、識別フィールド、値の
/// エンコーディングを知らずに、この汎用計画を処理します。
final class RemoteMutationDocument {
  RemoteMutationDocument({
    required Iterable<String> pathSegments,
    required Map<String, Object?> identityFields,
    required Map<String, Object?> encodedFields,
  })  : pathSegments = List.unmodifiable(pathSegments),
        identityFields = UnmodifiableMapView(Map.of(identityFields)),
        encodedFields = UnmodifiableMapView(Map.of(encodedFields)),
        assert(pathSegments.length >= 2 && pathSegments.length.isEven);

  final List<String> pathSegments;
  final Map<String, Object?> identityFields;
  final Map<String, Object?> encodedFields;
}

/// アプリケーションのリモートバックエンドに対して純粋なリモート変更要求を実行します。
/// SDK トランザクションと値のマッピングは実装が所有します。
abstract interface class RemoteMutationExecutor {
  Future<RemoteMutationAck> execute({
    required RemoteMutationDocument document,
    required RemoteMutationRequest request,
  });
}
