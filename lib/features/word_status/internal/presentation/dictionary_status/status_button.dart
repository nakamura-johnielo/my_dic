import 'dart:async';

import 'package:flutter/material.dart';
import 'package:my_dic/core/presentation/components/button/my_icon_button.dart';

abstract interface class WordStatusViewModel {
  bool get isLearned;
  bool get isBookmarked;
  bool get hasNote;
  bool get isLoading;
  String? get readError;
  Future<void> toggleLearned();
  Future<void> toggleBookmark();
  Future<void> toggleHasNote();
}

class DictionaryStatusButtons extends StatelessWidget {
  const DictionaryStatusButtons({super.key, required this.viewModel});
  final WordStatusViewModel viewModel;
  @override
  Widget build(BuildContext context) => _StatusButtons(viewModel: viewModel);
}

class MyWordStatusButtons extends StatelessWidget {
  const MyWordStatusButtons({super.key, required this.viewModel});
  final WordStatusViewModel viewModel;
  @override
  Widget build(BuildContext context) => _StatusButtons(viewModel: viewModel);
}

class _StatusButtons extends StatelessWidget {
  const _StatusButtons({required this.viewModel});
  final WordStatusViewModel viewModel;
  @override
  Widget build(BuildContext context) => Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (viewModel.isLoading)
            const Padding(
              padding: EdgeInsets.only(right: 6),
              child: SizedBox(
                width: 16,
                height: 16,
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
            ),
          if (viewModel.readError case final error?)
            Padding(
              padding: const EdgeInsets.only(right: 6),
              child: Tooltip(
                message: error,
                child: const Icon(Icons.error_outline_rounded, size: 18),
              ),
            ),
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
