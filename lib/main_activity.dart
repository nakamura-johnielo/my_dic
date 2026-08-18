import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:my_dic/app/routing/navigation_state.dart';
import 'package:my_dic/app/presentation/sync/manual_sync_action.dart';
import 'package:my_dic/core/presentation/components/nav_bar/item.dart';
import 'package:my_dic/core/presentation/components/nav_bar/studay_bottom_bar.dart';
import 'package:my_dic/core/shared/enums/entry_point.dart';
import 'package:my_dic/core/shared/consts/ui/tab.dart';
import 'package:my_dic/app/routing/route_names.dart';

import 'package:my_dic/core/shared/utils/logger.dart';

class MainActivity extends ConsumerStatefulWidget {
  const MainActivity({
    super.key,
    required this.navigationShell,
  });

  final StatefulNavigationShell navigationShell;

  @override
  ConsumerState<MainActivity> createState() => _MainActivityState();
}

class _MainActivityState extends ConsumerState<MainActivity> {
  static final int _studyBranchOffset = MainScreenTab.values
      .where((tab) => tab.entryPoint.category == EntryPointCategory.main)
      .length;
  static final int _studyTabIndexOnMainBar =
      MainScreenTab.values.indexOf(MainScreenTab.study);

  DestinatioinItem _buildDestinatioinItem(ScreenTabBehaivor tab) {
    return DestinatioinItem(icon: tab.icon, label: tab.label);
  }

  int _studyTabToShellIndex(int tabIndex) => tabIndex + _studyBranchOffset;

  int _mainTabToShellIndex(int tabIndex, int lastStudyTabIndex) {
    return tabIndex == _studyTabIndexOnMainBar
        ? _studyTabToShellIndex(lastStudyTabIndex)
        : tabIndex;
  }

  int _shellToVisibleTabIndex(
    int shellIndex,
    EntryPointCategory category,
  ) {
    return category == EntryPointCategory.study
        ? shellIndex - _studyBranchOffset
        : shellIndex.clamp(0, _studyTabIndexOnMainBar);
  }

  @override
  Widget build(BuildContext context) {
    final entryPoint = ref.watch(entryPointProvider);
    final selectedIndex = _shellToVisibleTabIndex(
      widget.navigationShell.currentIndex,
      entryPoint.category,
    );
    return Scaffold(
      extendBody: true,
      appBar: AppBar(
        title: Text(
          "My Dic",
        ),
        actions: [
          const ManualSyncAction(),
          IconButton(
              onPressed: () {
                context.pushNamed(RouteNames.profile);
              },
              icon: Icon(Icons.person))
        ],
      ),
      body: widget.navigationShell,
      bottomNavigationBar: SwitchableFloatBottomBar(
        entryPoint: entryPoint,
        selectedIndex: selectedIndex,
        destinationMap: {
          EntryPointCategory.main:
              MainScreenTab.values.map(_buildDestinatioinItem).toList(),
          EntryPointCategory.study:
              StudyScreenTab.values.map(_buildDestinatioinItem).toList(),
        },
        onDestinationSelected: (tabIndex) {
          if (tabIndex == selectedIndex) {
            AppLogger.print("00000000000000000000000000000");
            widget.navigationShell.goBranch(
              widget.navigationShell.currentIndex,
              initialLocation: true,
            );
            return;
          }
          final entryPoint = ref.read(entryPointProvider);
          AppLogger.print(
              "||||||||||||||||||||entrypoint current: $entryPoint");

          if (entryPoint.category == EntryPointCategory.study) {
            // Study内のタブ切り替え
            AppLogger.print(
                "study ||||||||||||||||||||entrypoint move: ${StudyScreenTab.values[tabIndex].entryPoint}");
            ref.read(entryPointProvider.notifier).state =
                StudyScreenTab.values[tabIndex].entryPoint;

            ref.read(lastStudyBranchTabIndexProvider.notifier).state = tabIndex;

            // Study内のStatefulNavigationShellを取得して切り替え
            // final nestedShell = navigationShell;
            // ネストしたShell内のタブを切り替え
            widget.navigationShell.goBranch(
              _studyTabToShellIndex(tabIndex),
              initialLocation:
                  false, //tabIndex == widget.navigationShell.currentIndex,
            );
          } else {
            // Main階層のタブ切り替え
            EntryPoint nextEntryPoint;
            if (tabIndex == 2) {
              final lastStudyIndex = ref.read(lastStudyBranchTabIndexProvider);
              nextEntryPoint = StudyScreenTab.values[lastStudyIndex].entryPoint;
            } else {
              nextEntryPoint = MainScreenTab.values[tabIndex].entryPoint;
              ref.read(lastMainBranchIndexProvider.notifier).state = tabIndex;
            }
            ref.read(entryPointProvider.notifier).state = nextEntryPoint;
            AppLogger.print(
                "main ||||||||||||||||||||entrypoint move: $nextEntryPoint");

            widget.navigationShell.goBranch(
              _mainTabToShellIndex(
                tabIndex,
                ref.read(lastStudyBranchTabIndexProvider),
              ),
              initialLocation: tabIndex == widget.navigationShell.currentIndex,
            );
          }
        },
        onActionButtonSelected: () {
          AppLogger.print(
              "!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!! CLOSE BUTTON TAPPED");
          final lastIndex = ref.read(lastMainBranchIndexProvider);
          EntryPoint lastEntryPoint;
          if (lastIndex == 0) {
            lastEntryPoint = EntryPoint.myword;
          } else if (lastIndex == 1) {
            lastEntryPoint = EntryPoint.search;
          } else {
            lastEntryPoint = EntryPoint.myword;
          }

          ref.read(entryPointProvider.notifier).state = lastEntryPoint;
          widget.navigationShell.goBranch(
            ref.read(lastMainBranchIndexProvider),
          );
        },
      ),
    );
  }
}
