import 'dart:collection';

import 'model/remote_mutation.dart';

/// Feature-owned, already encoded remote document plan.
///
/// Sync's external-system executor consumes this generic plan without knowing
/// dataset names, collection names, identity fields, or value encodings.
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

/// Executes a pure remote mutation request against the application's remote
/// backend. SDK transaction and value mapping are owned by the implementation.
abstract interface class RemoteMutationExecutor {
  Future<RemoteMutationAck> execute({
    required RemoteMutationDocument document,
    required RemoteMutationRequest request,
  });
}
