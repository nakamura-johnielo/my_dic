import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:my_dic/core/di/ui/ui_di.dart';
import 'package:my_dic/core/presentation/components/nav_bar/item.dart';
import 'package:my_dic/core/shared/consts/ui/ui.dart';
/* 
class MyNavigationBar extends StatelessWidget {
  const MyNavigationBar(
      {super.key,
      required this.selectedIndex,
      required this.destinations,
      this.onDestinationSelected});
  final int selectedIndex;
  final List<Widget> destinations;
  final void Function(int)? onDestinationSelected;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
      margin: const EdgeInsets.all(10.0),
      color: Colors.transparent,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(310.0),
        child: NavigationBar(
          selectedIndex: selectedIndex,
          destinations: destinations,
          onDestinationSelected: onDestinationSelected,
        ),
      ),
    ),

    SizedBox(width: 40,)
        /* Container(
          width: 60,
          height: 60,
          decoration: BoxDecoration(
            color: Colors.blue,
            shape: BoxShape.circle,
          ),
        ) */
      ],
    );
  }
}
 */

//
const double ICON_SIZE = 24; //default icon size
// const double height = 80; //一応デフォルトnavbar height 80
// const double margin = 10;

/* 
final NavigationBarThemeData navigationBarThemeData = NavigationBarThemeData(
  backgroundColor: AppColors.surfaceDim,
  indicatorColor: AppColors.primary,
  //shadowColor: Colors.white,
  //elevation: 10,
  labelTextStyle: WidgetStateProperty.all(
    const TextStyle(
        fontWeight: FontWeight.w600, color: AppColors.onSurfaceVariant),
  ),
  iconTheme: WidgetStateProperty.resolveWith<IconThemeData>((states) {
    if (states.contains(WidgetState.selected)) {
      return const IconThemeData(color: AppColors.onPrimary);
    }
    return const IconThemeData(color: AppColors.onSurfaceVariant);
  }),
); */
//

class FloatBottomBar extends ConsumerWidget {
  const FloatBottomBar(
      {super.key,
      required this.selectedIndex,
      required this.destinations,
      this.onDestinationSelected,
      this.onActionButtonSelected,
      this.backgroundColor = const Color.fromARGB(255, 249, 215, 255),
      this.indicatorColor = Colors.deepPurple,
      this.iconColors = const SelectedColors(
          selected: Colors.black87, unselected: Colors.black54),
      this.labelColors = const SelectedColors(
          selected: Colors.black87, unselected: Colors.black54)});
  final int selectedIndex;
  final List<DestinatioinItem> destinations;
  final void Function(int)? onDestinationSelected;
  final void Function()? onActionButtonSelected;
  final Color backgroundColor;
  final Color indicatorColor;
  final SelectedColors iconColors;
  final SelectedColors labelColors;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    const height = UIConsts.bottomBarHeight;
    const margin = UIConsts.margin;
    const marginBottom = margin * 2;

    // ref.read(bottomBarHeightProvider.notifier)
    //     .setHeight(marginBottom + UIConsts.bottomBarHeight);
    return Container(
      //width: double.infinity,
      margin: const EdgeInsets.fromLTRB(
          margin, 0, margin, marginBottom), //only(bottom: 20), //  all(10.0),
      color: Colors.transparent,

      // navbar & bottun
      child: Row(
        spacing: margin * 3,
        children: [
          // action button
          IconButton.filled(
            padding: EdgeInsets.all((height - 24) / 2),
            //color: Theme.of(context).colorScheme.surfaceDim,
            onPressed: () {
              onActionButtonSelected?.call();
            },
            icon: Icon(Icons.arrow_back_ios_new,
                color: Theme.of(context).colorScheme.onSurfaceVariant),
            style: ButtonStyle(
              backgroundColor: WidgetStateProperty.all(
                Theme.of(context).colorScheme.surfaceContainer,
              ),
            ),
          ),

          // GestureDetector(
          //   onTap: () {
          //     onActionButtonSelected?.call();
          //   },
          //   child: SizedBox(
          //       width: HEIGHT * 0.8,
          //       height: HEIGHT * 0.8,
          //       child: Container(
          //           decoration: BoxDecoration(
          //             color: selectedIndex == destinations.length
          //                 ? indicatorColor
          //                 : backgroundColor,
          //             shape: BoxShape.circle,
          //           ),
          //           child: Center(
          //             child: Icon(
          //               Icons.arrow_back_ios_new,
          //               color: selectedIndex == destinations.length
          //                   ? iconColors.selected
          //                   : iconColors.unselected,
          //               size: ICON_SIZE * 1.2,
          //             ),
          //           ))),
          // ),

          // navbar
          Expanded(
              child: ClipRRect(
            borderRadius: BorderRadius.circular(310.0),
            child: NavigationBar(
              height: height,
              selectedIndex: selectedIndex,
              destinations: List.generate(destinations.length, (index) {
                final icon = destinations[index].icon;
                final label = destinations[index].label;

                return NavigationDestination(icon: Icon(icon), label: label);
              }),

              // [
              //   NavigationDestination(
              //       icon: Icon(ScreenTab.myword.icon),
              //       label: ScreenTab.myword.label),
              //   // NavigationDestination(
              //   //     icon: Icon(ScreenTab.note.icon), label: ScreenTab.note.label),
              //   NavigationDestination(
              //       icon: Icon(ScreenTab.quiz.icon),
              //       label: ScreenTab.quiz.label),
              //   NavigationDestination(
              //       icon: Icon(ScreenTab.search.icon),
              //       label: ScreenTab.search.label),
              //   NavigationDestination(
              //       icon: Icon(ScreenTab.ranking.icon),
              //       label: ScreenTab.ranking.label),
              // ],
              onDestinationSelected: (index) {
                onDestinationSelected?.call(index);
              },
            ),

            // CustomNavigationBar(
            //   height: HEIGHT,
            //   selectedIndex: selectedIndex,
            //   destinations: destinations,
            //   onDestinationSelected: onDestinationSelected,
            //   backgroundColor: backgroundColor,
            //   iconColors: iconColors,
            //   labelColors: labelColors,
            //   //backgroundColor: AppColors.surfaceDim,
            //   indicatorColor: indicatorColor,
            //   iconSize: ICON_SIZE,
            // ),

            //
            /* NavigationBar(
              height: HEIGHT,
              selectedIndex: selectedIndex,
              destinations: destinations,
              onDestinationSelected: onDestinationSelected,
              //backgroundColor: AppColors.surfaceDim,
              //indicatorColor: AppColors.primary,
            ), */
          )),
        ],
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
