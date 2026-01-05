import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:my_dic/core/application/coordinator/auth_user_coordinator.dart';
import 'package:my_dic/features/auth/di/view_model_di.dart';
// import 'package:my_dic/core/application/services/remote_word_status_sync_service.dart';
import 'package:my_dic/features/user/di/viewmodel.dart';


// sigin signup signoutは個々から使える
final authUserCoordinatorProvider=Provider<AuthUserCoordinator>((ref){
  final auth=ref.watch(authCoordinatorProvider);
  final user=ref.watch(appUserCoordinatorProvider);
  return AuthUserCoordinator(auth: auth, user: user, ref: ref);
});