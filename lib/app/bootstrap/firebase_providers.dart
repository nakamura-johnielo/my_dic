// Firebase SDK composition belongs to application bootstrap.
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:my_dic/app/infrastructure/firebase/firebase_remote_mutation_executor.dart';
import 'package:my_dic/core/infrastructure/firebase/firebase_account_document_namespace.dart';
import 'package:my_dic/core/port/firebase_account_nested_document_gateway.dart';
import 'package:my_dic/features/auth/port/composition.dart';
import 'package:my_dic/features/sync/port/dataset_contract.dart';


final firestoreDBProvider = Provider((ref) => FirebaseFirestore.instance);
final firebaseAuthRuntimeProvider = Provider<AuthRuntimeGateway>(
  (ref) => FirebaseAuthDataSource(firebase_auth.FirebaseAuth.instance),
);

何か調べる
final firebaseAccountDocumentGatewayProvider =
    Provider<FirebaseAccountDocumentGateway>(
  (ref) => FirestoreAccountDocumentGateway(ref.watch(firestoreDBProvider)),
);

何か調べる
final remoteMutationExecutorProvider = Provider<RemoteMutationExecutor>(
  (ref) => FirebaseRemoteMutationExecutor(ref.watch(firestoreDBProvider)),
);

final class FirestoreAccountDocumentGateway
    implements FirebaseAccountDocumentGateway {
  FirestoreAccountDocumentGateway(this._firestore);

  final FirebaseFirestore _firestore;

  @override
  Future<FirebaseAccountDocument?> read(String accountId) async {
    final snapshot = await _firestore
        .collection(FirebaseAccountDocumentNamespace.usersCollection)
        .doc(accountId)
        .get();
    final data = snapshot.data();
    if (!snapshot.exists || data == null) return null;
    return FirebaseAccountDocument(
      id: snapshot.id,
      fields: data.map((key, value) => MapEntry(key, _normalize(value))),
    );
  }

  @override
  Future<FirebaseAccountDocument?> createIfAbsent({
    required String accountId,
    required Map<String, Object?> fields,
    required Set<String> serverTimestampFields,
  }) async {
    final reference = _firestore
        .collection(FirebaseAccountDocumentNamespace.usersCollection)
        .doc(accountId);
    final existing = await _firestore.runTransaction((transaction) async {
      final snapshot = await transaction.get(reference);
      final data = snapshot.data();
      if (snapshot.exists && data != null) {
        return FirebaseAccountDocument(
          id: snapshot.id,
          fields: data.map(
            (key, value) => MapEntry(key, _normalize(value)),
          ),
        );
      }
      transaction.set(reference, {
        for (final entry in fields.entries)
          entry.key: serverTimestampFields.contains(entry.key)
              ? FieldValue.serverTimestamp()
              : entry.value,
      });
      return null;
    });
    return existing;
  }

  Object? _normalize(Object? value) {
    if (value is Timestamp) return value.toDate().toUtc();
    if (value is DateTime) return value.toUtc();
    return value;
  }
}

/// Application-owned SDK adapter for generic nested account documents.
final class FirestoreAccountNestedDocumentGateway
    implements
        FirebaseAccountNestedDocumentGateway,
        FirebaseAccountNestedUpdatedDocumentGateway {
  FirestoreAccountNestedDocumentGateway(this._firestore);

  final FirebaseFirestore _firestore;

  @override
  Future<FirebaseAccountNestedDocument?> read({
    required String accountId,
    required String collection,
    required String documentId,
  }) async {
    final snapshot = await _collection(accountId, collection).doc(documentId).get();
    final data = snapshot.data();
    if (!snapshot.exists || data == null) return null;
    return _document(snapshot.id, data);
  }

  @override
  Future<List<FirebaseAccountNestedDocument>> fetchPage({
    required String accountId,
    required String collection,
    required String updatedAtField,
    required int? cursorSeconds,
    required int? cursorNanoseconds,
    required String? cursorDocumentId,
  }) async {
    Query<Map<String, dynamic>> query = _collection(accountId, collection)
        .orderBy(updatedAtField)
        .orderBy(FieldPath.documentId);
    if (cursorSeconds != null &&
        cursorNanoseconds != null &&
        cursorDocumentId != null) {
      query = query.startAt([
        Timestamp(cursorSeconds, cursorNanoseconds),
        cursorDocumentId,
      ]);
    }
    final snapshot = await query.get();
    return snapshot.docs
        .map((document) => _document(document.id, document.data()))
        .toList(growable: false);
  }

  @override
  Future<List<FirebaseAccountNestedDocument>> fetchUpdatedSince({
    required String accountId,
    required String collection,
    required String updatedAtField,
    required DateTime since,
  }) async {
    final snapshot = await _collection(accountId, collection)
        .where(
          updatedAtField,
          isGreaterThanOrEqualTo: Timestamp.fromDate(since),
        )
        .get();
    return snapshot.docs
        .map((document) => _document(document.id, document.data()))
        .toList(growable: false);
  }

  CollectionReference<Map<String, dynamic>> _collection(
    String accountId,
    String collection,
  ) =>
      _firestore
          .collection(FirebaseAccountDocumentNamespace.usersCollection)
          .doc(accountId)
          .collection(collection);

  FirebaseAccountNestedDocument _document(
    String id,
    Map<String, dynamic> data,
  ) =>
      FirebaseAccountNestedDocument(
        id: id,
        fields: data.map((key, value) => MapEntry(key, _normalize(value))),
      );

  Object? _normalize(Object? value) {
    if (value is Timestamp) return value.toDate().toUtc();
    if (value is DateTime) return value.toUtc();
    return value;
  }
}

/// Application-owned Firebase adapter for Auth's SDK-free runtime contract.
final class FirebaseAuthDataSource implements AuthRuntimeGateway {
  FirebaseAuthDataSource(this._auth);

  final firebase_auth.FirebaseAuth _auth;

  @override
  Stream<AuthRuntimeIdentity?> observeAuthState() =>
      _auth.userChanges().map(_identityFromUserOrNull);

  @override
  Future<AuthRuntimeIdentity?> createUserWithEmailAndPassword(
    String email,
    String password,
  ) =>
      _firebaseCall(() async {
        final credential = await _auth.createUserWithEmailAndPassword(
          email: email,
          password: password,
        );
        return _identityFromCredential(credential);
      });

  @override
  Future<AuthRuntimeIdentity?> signInWithEmailAndPassword(
    String email,
    String password,
  ) =>
      _firebaseCall(() async {
        final credential = await _auth.signInWithEmailAndPassword(
          email: email,
          password: password,
        );
        return _identityFromCredential(credential);
      });

  @override
  Future<void> signOut() => _firebaseCall(_auth.signOut);

  @override
  Future<void> sendEmailVerification() => _firebaseCall(() async {
        final user = _auth.currentUser;
        if (user != null && !user.emailVerified) {
          await user.sendEmailVerification();
        }
      });

  @override
  Future<void> sendPasswordResetEmail({required String email}) =>
      _firebaseCall(() => _auth.sendPasswordResetEmail(email: email));

  @override
  Future<AuthRuntimeIdentity?> getCurrentAuth() async =>
      _identityFromUserOrNull(_auth.currentUser);

  @override
  Future<AuthRuntimeIdentity?> reloadCurrentAuth() => _firebaseCall(() async {
        final user = _auth.currentUser;
        if (user == null) return null;
        await user.reload();
        return _identityFromUserOrNull(_auth.currentUser);
      });

  Future<T> _firebaseCall<T>(Future<T> Function() operation) async {
    try {
      return await operation();
    } on firebase_auth.FirebaseAuthException catch (error, stackTrace) {
      throw AuthRuntimeFailure(
        code: error.code,
        message: error.message,
        originalError: error,
        stackTrace: stackTrace,
      );
    }
  }

  AuthRuntimeIdentity? _identityFromCredential(
    firebase_auth.UserCredential credential,
  ) {
    final user = credential.user;
    if (user == null) return null;
    return _identityFromUser(
      user,
      credentialProviderId: credential.credential?.providerId,
    );
  }

  AuthRuntimeIdentity? _identityFromUserOrNull(firebase_auth.User? user) =>
      user == null ? null : _identityFromUser(user);

  AuthRuntimeIdentity _identityFromUser(
    firebase_auth.User user, {
    String? credentialProviderId,
  }) {
    if (user.uid.isEmpty) throw Exception('User ID is empty');
    return AuthRuntimeIdentity(
      accountId: user.uid,
      email: user.email,
      emailVerified: user.emailVerified,
      credentialProviderId: credentialProviderId,
    );
  }
}
