/// SDK-free document value below the shared account-document namespace.
final class FirebaseAccountNestedDocument {
  const FirebaseAccountNestedDocument({
    required this.id,
    required this.fields,
  });

  final String id;
  final Map<String, Object?> fields;
}

/// Technical contract for an account-owned nested document collection.
///
/// This contract deliberately contains no Firebase SDK types. Concrete
/// Firebase mechanics remain in infrastructure implementations.
abstract interface class FirebaseAccountNestedDocumentGateway {
  Future<FirebaseAccountNestedDocument?> read({
    required String accountId,
    required String collection,
    required String documentId,
  });

  Future<List<FirebaseAccountNestedDocument>> fetchPage({
    required String accountId,
    required String collection,
    required String updatedAtField,
    required int? cursorSeconds,
    required int? cursorNanoseconds,
    required String? cursorDocumentId,
  });
}

/// Technical contract for legacy inclusive `updatedAt >= since` dataset pulls.
abstract interface class FirebaseAccountNestedUpdatedDocumentGateway {
  Future<FirebaseAccountNestedDocument?> read({
    required String accountId,
    required String collection,
    required String documentId,
  });

  Future<List<FirebaseAccountNestedDocument>> fetchUpdatedSince({
    required String accountId,
    required String collection,
    required String updatedAtField,
    required DateTime since,
  });
}
