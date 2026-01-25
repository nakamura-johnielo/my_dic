import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
//

import 'package:flutter/material.dart';
import 'package:my_dic/core/presentation/components/button/my_icon_button.dart';
import 'package:my_dic/features/esp_jpn_word_status/di/di.dart';
import 'package:my_dic/features/auth/di/service.dart';

class StatusButtons extends ConsumerWidget {
  const StatusButtons({super.key, required this.wordId});
  final int wordId;

  static const Map<String, IconData> bookmarkIcon = {
    "true": Icons.bookmark_rounded,
    "false": Icons.bookmark_border_rounded,
    "added": Icons.bookmark_added_rounded,
  };

  static const Map<String, IconData> learnedIcon = {
    "true": Icons.check_circle_rounded,
    "false": Icons.check_circle_outline_rounded,
  };

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // final wordStatus = ref.watch(wordStatusByIdProvider(wordId));
    final wordStatus = ref.watch(espJpnWordStatusUiStateProvider(wordId));
    final command =
        ref.read(espJpnWordStatusCommandProvider(wordId).notifier);
    //controller.init(wordId); //初期化

    // final userId = ref.watch(authStoreNotifierProvider.select((a)=>a?.accountId)) ;

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        MyIconButton(
          iconSize: 22,
          defaultIcon: wordStatus.isLearned 
              ? learnedIcon["true"] ?? Icons.error
              : learnedIcon["false"] ?? Icons.error,
          hoveredIcon: wordStatus.isLearned 
              ? learnedIcon["true"] ?? Icons.error
              : learnedIcon["false"] ?? Icons.error,
          hoveredIconColor: const Color.fromARGB(255, 119, 119, 119),
          onTap: () {
            unawaited(command.toggleLearned( wordStatus.isLearned));
          },
        ),
        const SizedBox(width: 3),
        MyIconButton(
          iconSize: 24,
          defaultIcon: wordStatus.isBookmarked 
              ? bookmarkIcon["true"] ?? Icons.error
              : bookmarkIcon["false"] ?? Icons.error,
          hoveredIcon: wordStatus.isBookmarked 
              ? bookmarkIcon["true"] ?? Icons.error
              : bookmarkIcon["false"] ?? Icons.error,
          hoveredIconColor: const Color.fromARGB(255, 119, 119, 119),
          onTap: () {
            unawaited(command.toggleBookmark( wordStatus.isBookmarked));
          },
        ),
      ],
    );
  }
}

