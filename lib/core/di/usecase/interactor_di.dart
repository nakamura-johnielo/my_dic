import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:my_dic/DI/riverpod.dart';
import 'package:my_dic/core/di/data/repository_di.dart';
import 'package:my_dic/core/domain/usecase/esp_jpn_status/esp_jpn_status_interactor.dart';

final espJpnStatusInteractorProvider = Provider<EspJpnStatusInteractor>((ref) {
  return EspJpnStatusInteractor(ref.read(esjWordRepositoryProvider));
});

final espJpnUpdateInteractorProvider =
    Provider<EspJpnStatusUpdateInteractor>((ref) {
  return EspJpnStatusUpdateInteractor(ref.read(wordStatusRepositoryProvider));
});
