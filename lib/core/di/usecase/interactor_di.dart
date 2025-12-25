import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:my_dic/core/di/service/riverpod.dart';
import 'package:my_dic/core/di/data/repository_di.dart';
import 'package:my_dic/core/domain/usecase/fetch_esp_jpn_status/fetch__esp_jpn_status_interactor.dart';
import 'package:my_dic/core/domain/usecase/fetch_esp_jpn_status/fetch_esp_jpn_status_usecase.dart';

// final espJpnStatusInteractorProvider = Provider<EspJpnStatusInteractor>((ref) {
//   return EspJpnStatusInteractor(ref.read(esjWordRepositoryProvider));
// });

// final espJpnUpdateInteractorProvider =
//     Provider<EspJpnStatusUpdateInteractor>((ref) {
//   return EspJpnStatusUpdateInteractor(ref.read(wordStatusRepositoryProvider));
// });


