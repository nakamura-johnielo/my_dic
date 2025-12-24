
import 'package:flutter_riverpod/flutter_riverpod.dart';

// final remoteSyncWordStatusEffectProvider = Provider<void>((ref) {
//   ref.listen<AsyncValue<AppAuth?>>(
//     authStreamProvider,
//     (previous, next) async {
//       final currentAuth = next.value;
//       if (currentAuth != null) {
//         ref
//             .read(espJpnWordStatusSyncServiceProvider)
//             .startSyncWithRemote(currentAuth.userId);
//       } else {
//         ref.read(espJpnWordStatusSyncServiceProvider).dispose();
//       }
//     },
//   );
// });