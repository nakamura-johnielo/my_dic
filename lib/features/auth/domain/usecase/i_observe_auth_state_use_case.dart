import 'package:my_dic/core/domain/entity/auth.dart';

abstract interface class IObserveAuthStateUseCase {
  Stream<AppAuth?> execute();
}
