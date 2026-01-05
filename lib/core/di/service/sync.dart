import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:my_dic/features/esp_jpn_word_status/services/remote_word_status_sync_service.dart';
import 'package:my_dic/core/di/usecase/usecase_di.dart';
import 'package:my_dic/features/auth/di/service.dart';
// import 'package:my_dic/core/application/services/remote_word_status_sync_service.dart';
import 'package:my_dic/features/user/di/viewmodel.dart';

// final espJpnWordStatusSyncProvider = StreamProvider.autoDispose<void>((ref) {
//   final useCase = ref.read(espJpnWordStatusSyncServiceProvider);
//   return useCase.startSyncWithRemote();
// });


// final espJpnWordStatusSyncProvider = Provider.autoDispose<void>((ref) {
//   final userId = ref.watch(userViewModelProvider)?.id;
  
//   if (userId == null || userId.isEmpty) {
//     // ログアウト状態では何もしない
//     return;
//   }

//   final service = ref.watch(espJpnWordStatusSyncServiceProvider);
//   final sub = service.startSyncWithRemote(userId);

//   ref.onDispose(() {
//     sub.cancel();
//   });
// });


// final espJpnWordStatusSyncServiceProvider =
//     Provider<EspJpnWordStatusSyncService>((ref) {
//   final syncEspJpnWordStatusUseCase =
//       ref.read(syncEspJpnWordStatusUseCaseProvider);
//   return EspJpnWordStatusSyncService(syncEspJpnWordStatusUseCase);
// });



// //userIdで
// final espJpnWordStatusSyncProvider = Provider.autoDispose.family<void, String>((ref, userId) {
//   if (userId.isEmpty) {
//     return;
//   }

//   final service = ref.watch(espJpnWordStatusSyncServiceProvider);
//   final sub = service.startSyncWithRemote(userId);

//   ref.onDispose(() {
//     sub.cancel();
//   });
// });


// // ラッパープロバイダーで自動化
// final autoEspJpnWordStatusSyncProvider = Provider.autoDispose<void>((ref) {
//   final userId = ref.watch(authStoreNotifierProvider.select((a)=>a?.accountId));
  
//   if (userId == null || userId.isEmpty|| userId != "logout" || userId != "anonymous") {
//     return;
//   }
  
//   // familyプロバイダーを呼び出し
//   ref.watch(espJpnWordStatusSyncProvider(userId));
// });