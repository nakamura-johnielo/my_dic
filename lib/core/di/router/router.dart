
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:my_dic/core/shared/enums/entry_point.dart';

final entryPointProvider =
    StateProvider<EntryPoint>((_) => EntryPoint.search);


    final lastMainBranchIndexProvider = StateProvider<int>((_) => 1);
    final lastStudyBranchTabIndexProvider = StateProvider<int>((_) => 2);