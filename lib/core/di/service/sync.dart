import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:my_dic/core/di/usecase/usecase_di.dart';
import 'package:my_dic/core/application/services/remote_word_status_sync_service.dart';


final espJpnWordStatusSyncServiceProvider =
    Provider<EspJpnWordStatusSyncService>((ref) {
  final syncEspJpnWordStatusUseCase =
      ref.read(syncEspJpnWordStatusUseCaseProvider);
  return EspJpnWordStatusSyncService(syncEspJpnWordStatusUseCase);
});