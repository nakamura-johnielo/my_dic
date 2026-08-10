import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Firebase SDK access is confined to UserProfile's canonical adapter.
final userProfileFirestoreProvider =
    Provider<FirebaseFirestore>((_) => FirebaseFirestore.instance);
