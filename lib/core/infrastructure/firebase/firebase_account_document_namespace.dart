/// Shared technical ownership of the top-level Firebase account-document path.
///
/// Feature-owned nested collections and payload fields do not belong here.
abstract final class FirebaseAccountDocumentNamespace {
  static const usersCollection = 'Users';
}

/// SDK-free snapshot of one document in the shared account namespace.
final class FirebaseAccountDocument {
  const FirebaseAccountDocument({required this.id, required this.fields});

  final String id;
  final Map<String, Object?> fields;
}

/// SDK-free technical reader for the shared account-document namespace.
abstract interface class FirebaseAccountDocumentGateway {
  Future<FirebaseAccountDocument?> read(String accountId);

  /// Atomically creates the account document when it does not exist.
  ///
  /// Returns the existing document when one is already present, otherwise
  /// returns `null` after creating it. Field meaning remains owned by the
  /// calling feature; this gateway only owns the external-system operation.
  Future<FirebaseAccountDocument?> createIfAbsent({
    required String accountId,
    required Map<String, Object?> fields,
    required Set<String> serverTimestampFields,
  });
}
