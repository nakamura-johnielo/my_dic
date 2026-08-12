import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:my_dic/features/my_word/internal/infrastructure/my_word/firebase/firebase_my_word_dao.dart';
import 'package:my_dic/features/my_word/internal/infrastructure/my_word/firebase/firebase_my_word_data_source.dart';
import 'package:my_dic/features/my_word/port/composition.dart';
import 'package:my_dic/features/sync/port/composition_contract.dart';
import 'package:my_dic/features/sync/port/remote_mutation_executor.dart';

/// Builds the Firebase-backed MyWord remote adapter inside its canonical
/// Firebase infrastructure boundary.
FirebaseMyWordDataSource createInternalFirebaseMyWordRemoteDataSource(
  SyncDependencyReaderPort read,
) =>
    FirebaseMyWordDataSource(
      FirebaseMyWordDao(
        read<FirebaseFirestore>(MyWordSyncDependency.firestore),
        read<RemoteMutationExecutor>(
            MyWordSyncDependency.remoteMutationExecutor),
      ),
    );
