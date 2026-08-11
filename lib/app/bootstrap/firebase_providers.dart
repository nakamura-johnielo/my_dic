// Firebase SDK composition belongs to application bootstrap.
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:my_dic/integration/sync/firebase_remote_mutation_executor.dart';
import 'package:my_dic/features/sync/port/remote_mutation_executor.dart';

final firestoreDBProvider = Provider((ref) => FirebaseFirestore.instance);
final firestoreAuthProvider = Provider((ref) => FirebaseAuth.instance);
final remoteMutationExecutorProvider = Provider<RemoteMutationExecutor>(
  (ref) => FirebaseRemoteMutationExecutor(ref.watch(firestoreDBProvider)),
);
