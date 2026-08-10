import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Firebase SDK access is confined to Auth's canonical Firebase adapter.
final authFirebaseAuthProvider = Provider<FirebaseAuth>((_) => FirebaseAuth.instance);
