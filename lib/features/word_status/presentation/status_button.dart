import 'dart:async';

import 'package:flutter/material.dart';
import 'package:my_dic/core/presentation/components/button/my_icon_button.dart';

abstract interface class WordStatusViewModel {
  bool get isLearned;
  bool get isBookmarked;
  bool get hasNote;

  Future<void> toggleLearned();
  Future<void> toggleBookmark();
  Future<void> toggleHasNote();
}

/// Shared presentation component for dictionary word status.
///
/// Dataset-specific repository and sync details are resolved by the app-level
/// composition adapter before this shared component is built.
class DictionaryStatusButtons extends StatelessWidget {
  const DictionaryStatusButtons({
    super.key,
    required this.viewModel,
  });

  final WordStatusViewModel viewModel;

  @override
  Widget build(BuildContext context) {
    return _StatusButtons(viewModel: viewModel);
  }
}

class MyWordStatusButtons extends StatelessWidget {
  const MyWordStatusButtons({super.key, required this.viewModel});

  final WordStatusViewModel viewModel;

  @override
  Widget build(BuildContext context) {
    return _StatusButtons(viewModel: viewModel);
  }
}

class _StatusButtons extends StatelessWidget {
  const _StatusButtons({required this.viewModel});

  final WordStatusViewModel viewModel;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        MyIconButton(
          iconSize: 22,
          defaultIcon: viewModel.isLearned
              ? Icons.check_circle_rounded
              : Icons.check_circle_outline_rounded,
          hoveredIcon: viewModel.isLearned
              ? Icons.check_circle_rounded
              : Icons.check_circle_outline_rounded,
          hoveredIconColor: const Color.fromARGB(255, 119, 119, 119),
          onTap: () => unawaited(viewModel.toggleLearned()),
        ),
        const SizedBox(width: 3),
        MyIconButton(
          iconSize: 24,
          defaultIcon: viewModel.isBookmarked
              ? Icons.bookmark_rounded
              : Icons.bookmark_border_rounded,
          hoveredIcon: viewModel.isBookmarked
              ? Icons.bookmark_rounded
              : Icons.bookmark_border_rounded,
          hoveredIconColor: const Color.fromARGB(255, 119, 119, 119),
          onTap: () => unawaited(viewModel.toggleBookmark()),
        ),
      ],
    );
  }
}
