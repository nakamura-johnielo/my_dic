import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Firebase SDK access is confined to MyWord's canonical adapter.
final myWordFirestoreProvider =
    Provider<FirebaseFirestore>((_) => FirebaseFirestore.instance);
