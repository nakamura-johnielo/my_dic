import 'package:my_dic/features/auth/domain/entity/app_auth.dart';

abstract interface class IObserveAuthStateUseCase {
  Stream<AppAuth?> execute();
}
