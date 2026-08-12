import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:my_dic/features/sync/port/composition_contract.dart';
import 'package:my_dic/features/sync/port/remote_mutation_executor.dart';
import 'package:my_dic/features/word_status/internal/infrastructure/esp_jpn/firebase/firebase_esp_jpn_word_status_dao.dart';
import 'package:my_dic/features/word_status/internal/infrastructure/esp_jpn/firebase/firebase_esp_jpn_word_status_remote_store.dart';
import 'package:my_dic/features/word_status/port/composition.dart';

/// Builds the Firebase-backed EspJpn status remote store in canonical Firebase
/// infrastructure, keeping feature composition SDK-free.
FirebaseEspJpnWordStatusRemoteStore
    createInternalFirebaseEspJpnWordStatusRemoteStore(
            SyncDependencyReaderPort read) =>
        FirebaseEspJpnWordStatusRemoteStore(
          FirebaseEspJpnWordStatusDao(
            read<FirebaseFirestore>(WordStatusSyncDependency.firestore),
            read<IRemoteMutationExecutor>(
              WordStatusSyncDependency.remoteMutationExecutor,
            ),
          ),
        );
