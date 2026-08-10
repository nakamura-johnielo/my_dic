import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:my_dic/features/sync/port/composition_contract.dart';
import 'package:my_dic/features/sync/port/remote_mutation_executor.dart';
import 'package:my_dic/features/word_status/internal/infrastructure/jpn_esp/firebase/firebase_jpn_esp_word_status_dao.dart';
import 'package:my_dic/features/word_status/internal/infrastructure/jpn_esp/firebase/firebase_jpn_esp_word_status_remote_store.dart';
import 'package:my_dic/features/word_status/port/composition.dart';

/// Builds the Firebase-backed JpnEsp status remote store in canonical Firebase
/// infrastructure, keeping feature composition SDK-free.
FirebaseJpnEspWordStatusRemoteStore
createInternalFirebaseJpnEspWordStatusRemoteStore(SyncDependencyReader read) =>
    FirebaseJpnEspWordStatusRemoteStore(
      FirebaseJpnEspWordStatusDao(
        read<FirebaseFirestore>(WordStatusSyncDependency.firestore),
        read<RemoteMutationExecutor>(
          WordStatusSyncDependency.remoteMutationExecutor,
        ),
      ),
    );
