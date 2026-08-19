import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:my_dic/core/presentation/components/nav_bar/animation.dart';
import 'package:my_dic/core/presentation/components/nav_bar/item.dart';
import 'package:my_dic/core/shared/consts/ui/tooltips.dart';
import 'package:my_dic/core/shared/consts/ui/ui.dart';
import 'package:my_dic/core/shared/enums/entry_point.dart';
import 'package:my_dic/core/shared/utils/screen_size.dart';

const double iconSize = 24; // デフォルトのアイコンサイズ

class SwitchableFloatBottomBar extends ConsumerWidget {
  const SwitchableFloatBottomBar(
      {super.key,
      required this.selectedIndex,
      required this.destinationMap,
      this.onDestinationSelected,
      this.onActionButtonSelected,
      this.backgroundColor = const Color.fromARGB(255, 249, 215, 255),
      this.indicatorColor = Colors.deepPurple,
      this.iconColors = const SelectedColors(
          selected: Colors.black87, unselected: Colors.black54),
      this.labelColors = const SelectedColors(
          selected: Colors.black87, unselected: Colors.black54),
      required this.entryPoint});
  final int selectedIndex;
  final EntryPoint entryPoint;
  final Map<EntryPointCategory, List<DestinatioinItem>> destinationMap;
  final void Function(int)? onDestinationSelected;
  final void Function()? onActionButtonSelected;
  final Color backgroundColor;
  final Color indicatorColor;
  final SelectedColors iconColors;
  final SelectedColors labelColors;

  double getBackBtnHeight(BuildContext context) {
    if (ScreenSize.isSmall(context)) {
      return UIConsts.bottomBarHeight * 0.8;
    } else {
      return UIConsts.bottomBarHeight;
    }
  }

  double getRowSpacing(BuildContext context) {
    if (ScreenSize.isSmall(context)) {
      return UIConsts.margin * 1;
    } else {
      return UIConsts.margin * 3;
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    const height = UIConsts.bottomBarHeight;
    const margin = UIConsts.margin;
    const marginBottom = margin * 2;
    return Container(
      margin: const EdgeInsets.fromLTRB(
          margin, 0, margin, marginBottom), //only(bottom: 20), //  all(10.0),
      color: Colors.transparent,

      // ナビゲーションバーとボタン
      child: Row(
        children: [
          HorizontalFader(
              height: getBackBtnHeight(context),
              isVisible: entryPoint.category == EntryPointCategory.study,
              child: Tooltip(
                message: AppTooltips.back2Main,
                preferBelow: false,
                child: IconButton.filled(
                  padding: EdgeInsets.all((getBackBtnHeight(context) - 24) / 2),
                  onPressed: () {
                    onActionButtonSelected?.call();
                  },
                  icon: Icon(Icons.arrow_back_ios_new,
                      color: Theme.of(context).colorScheme.onSurfaceVariant),
                  style: ButtonStyle(
                    backgroundColor: WidgetStateProperty.all(
                      Theme.of(context).colorScheme.surfaceContainer,
                    ),
                    overlayColor: WidgetStateProperty.all(
                      Theme.of(context)
                          .colorScheme
                          .primary
                          .withValues(alpha: 0.1),
                    ),
                  ),
                ),
              )),
          HorizontalFader(
              height: height,
              isVisible: entryPoint.category == EntryPointCategory.study,
              child: SizedBox(
                width: getRowSpacing(context),
              )),

          // ナビゲーションバー
          Expanded(child: _buildBar(destinationMap[entryPoint.category] ?? [])),
        ],
      ),
    );
  }

  Widget _buildBar(List<DestinatioinItem> destinations) {
    const height = UIConsts.bottomBarHeight;
    return ClipRRect(
      borderRadius: BorderRadius.circular(310.0),
      child: NavigationBar(
        height: height,
        selectedIndex: selectedIndex,
        destinations: List.generate(destinations.length, (index) {
          final icon = destinations[index].icon;
          final label = destinations[index].label;

          return NavigationDestination(icon: Icon(icon), label: label);
        }),
        onDestinationSelected: (index) {
          onDestinationSelected?.call(index);
        },
      ),
    );
  }
}

//
///
///
///
///

class CustomNavigationBar extends StatelessWidget {
  const CustomNavigationBar(
      {super.key,
      required this.selectedIndex,
      required this.destinations,
      this.onDestinationSelected,
      this.height = 80,
      this.backgroundColor = Colors.white30,
      this.indicatorColor = Colors.deepPurple,
      this.iconColors = const SelectedColors(
          selected: Colors.black87, unselected: Colors.black54),
      this.labelColors = const SelectedColors(
          selected: Colors.black87, unselected: Colors.black54),
      required this.iconSize});
  final int selectedIndex;
  final List<DestinatioinItem> destinations;
  final void Function(int)? onDestinationSelected;
  final double height;
  final Color backgroundColor;
  final Color indicatorColor;
  final SelectedColors iconColors;
  final SelectedColors labelColors;
  final double iconSize;
  //final List<_NavItem> navItems;

  @override
  Widget build(BuildContext context) {
    return /* SizedBox(
      height: height, 
      child:*/
        Container(
      padding: const EdgeInsets.symmetric(vertical: 12),
      decoration: BoxDecoration(
        color: backgroundColor,
        //borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: List.generate(destinations.length, (index) {
          final item = destinations[index];
          final isSelected = selectedIndex == index;

          return GestureDetector(
            onTap: () {
              if (onDestinationSelected != null) {
                onDestinationSelected!(index);
              }
            },
            child: Column(
              spacing: 2,
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                    padding: EdgeInsets.symmetric(
                        horizontal: iconSize * 0.6, vertical: 2),
                    decoration: BoxDecoration(
                        color: isSelected ? indicatorColor : Colors.transparent,
                        borderRadius:
                            const BorderRadius.all(Radius.circular(120))),
                    child: Icon(item.icon,
                        size: iconSize,
                        color: isSelected
                            ? iconColors.selected
                            : iconColors.unselected)),

                // label非表示
                /* Text(
                    item.label,
                    style: TextStyle(
                      color: isSelected
                          ? labelColors.selected
                          : labelColors.unselected,
                      fontWeight:
                          isSelected ? FontWeight.w500 : FontWeight.w400,
                    ),
                  ), */
              ],
            ),
          );
        }),
      ),
      // ),
    );
  }
}

//
