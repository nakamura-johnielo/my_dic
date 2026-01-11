import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:my_dic/core/di/router/router.dart';
import 'package:my_dic/core/di/ui/ui_di.dart';
import 'package:my_dic/core/presentation/components/nav_bar/item.dart';
import 'package:my_dic/core/presentation/components/nav_bar/studay_bottom_bar.dart';
import 'package:my_dic/core/shared/consts/ui/ui.dart';
import 'package:my_dic/core/shared/enums/entry_point.dart';
import 'package:my_dic/core/shared/enums/ui/tab.dart';
import 'package:my_dic/router/route_names.dart';

class StudyActivity extends ConsumerWidget {
  const StudyActivity({
    super.key,
    required this.navigationShell,
  });

  final StatefulNavigationShell navigationShell;

  DestinatioinItem _buildDestinatioinItem(ScreenTabBehaivor tab) {
    return DestinatioinItem(icon: tab.icon, label: tab.label);
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final entryPoint = ref.watch(entryPointProvider);

    return Scaffold(
      extendBody: true,
      body: navigationShell,
      bottomNavigationBar: 
      FloatBottomBar(
        selectedIndex: navigationShell.currentIndex,
        destinations:
            StudyScreenTab.values.map(_buildDestinatioinItem).toList(),
        // backgroundColor: AppColors.surfaceContainer,
        // indicatorColor: AppColors.primary,
        // iconColors: SelectedColors(
        //   selected: AppColors.onPrimary,
        //   unselected: AppColors.onSurfaceVariant,
        // ),
        // labelColors: SelectedColors(
        //   selected: AppColors.onSurface,
        //   unselected: AppColors.onSurfaceVariant,
        // ),
        onDestinationSelected: (index) {
          print("Study内のタブ切り替え: index=$index");

          // EntryPointを更新
          ref.read(entryPointProvider.notifier).state =
              StudyScreenTab.values[index].entryPoint;

          // Study内のネストしたShellのタブを切り替え
          navigationShell.goBranch(
            index,
            initialLocation: index == navigationShell.currentIndex,
          );
        },
        onActionButtonSelected: () {
          print("Study Close button tapped");
          //TODO EntryPointどこに戻るか
          ref.read(entryPointProvider.notifier).state =
              MainScreenTab.values[1].entryPoint;
          // Main階層のsearchタブに遷移
          context.pop();
          // context.go('/${RoutePaths.search}');
        },
      ),
    );
  }
}
