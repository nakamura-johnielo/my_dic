export 'package:my_dic/features/word_status/port/composition_contract.dart'
    show WordStatusClock;

import 'package:my_dic/features/word_status/port/composition_contract.dart';

final class SystemWordStatusClock implements WordStatusClock {
  const SystemWordStatusClock();

  @override
  DateTime now() => DateTime.now();
}
