import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:my_dic/features/my_word/internal/infrastructure/my_word_status/firebase/firebase_my_word_status_dao.dart';
import 'package:my_dic/features/my_word/internal/infrastructure/my_word_status/firebase/firebase_my_word_status_data_source.dart';
import 'package:my_dic/features/my_word/port/composition.dart';
import 'package:my_dic/features/sync/port/composition_contract.dart';
import 'package:my_dic/features/sync/port/remote_mutation_executor.dart';

/// Builds the Firebase-backed MyWordStatus remote adapter inside its canonical
/// Firebase infrastructure boundary.
FirebaseMyWordStatusDataSource
    createInternalFirebaseMyWordStatusRemoteDataSource(
            SyncDependencyReaderPort read) =>
        FirebaseMyWordStatusDataSource(
          FirebaseMyWordStatusDao(
            read<FirebaseFirestore>(MyWordSyncDependency.firestore),
            read<IRemoteMutationExecutor>(
              MyWordSyncDependency.remoteMutationExecutor,
            ),
          ),
        );
