import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:my_dic/core/di/router/router.dart';
import 'package:my_dic/core/di/ui/ui_di.dart';
import 'package:my_dic/core/presentation/components/nav_bar/item.dart';
import 'package:my_dic/core/presentation/components/nav_bar/studay_bottom_bar.dart';
import 'package:my_dic/core/shared/consts/ui/ui.dart';
import 'package:my_dic/core/shared/enums/ui/tab.dart';
//import 'package:my_dic/Constants/screen_tab.dart';

class MainActivity extends ConsumerWidget {
  const MainActivity({
    super.key,
    required this.navigationShell,
  });

  final StatefulNavigationShell navigationShell;

  DestinatioinItem _buildDestinatioinItem(ScreenTab tab) {
    return DestinatioinItem(icon: tab.icon, label: tab.label);
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
//  final double bottomBarHeight = UIConsts.bottomBarHeight + MediaQuery.of(context).padding.bottom;

    // ref.read(bottomBarHeightProvider.notifier).setHeight( bottomBarHeight);


    return Scaffold(
      extendBody: true,
      appBar: AppBar(
        title: Text(
          "My Dic",
        ),
        actions: [
          IconButton(
              onPressed: () {
                context
                    .push('/${ScreenTab.profile}/${ScreenPage.unAuthorized}');
              },
              icon: Icon(Icons.person))
        ],
      ),

      body: navigationShell,

      bottomNavigationBar: FloatBottomBar(
        selectedIndex: navigationShell.currentIndex,
        destinations: [
          _buildDestinatioinItem(ScreenTab.myword),
          _buildDestinatioinItem(ScreenTab.search),
          _buildDestinatioinItem(ScreenTab.study),
        ],
        onDestinationSelected: (index) {
          ref.read(entryPointProvider.notifier).state=ScreenTab.values[index].entryPoint;
          navigationShell.goBranch(
            index,
            initialLocation: index == navigationShell.currentIndex,
          );
        },
        onActionButtonSelected: () {
          //navigationShell.goBranch(3, initialLocation: false);
          print("!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!! CLOSE BUTTON TAPPED");
        },
      ),

      //  Stack(
      //   children: [
      //     // bodyコンテンツ
      //     Positioned.fill(child: navigationShell),

      //     // ナビゲーションバー
      //     Positioned(
      //       left: 0,
      //       right: 0,
      //       bottom: 0,
      //       child: FloatBottomBar(
      //         // backgroundColor: AppColors.surfaceContainer,
      //         // indicatorColor: AppColors.primary,
      //         // iconColors: SelectedColors(
      //         //     selected: AppColors.onPrimary,
      //         //     unselected: AppColors.onSurfaceVariant),
      //         // labelColors: SelectedColors(
      //         //     selected: AppColors.onSurface,
      //         //     unselected: AppColors.onSurfaceVariant),
      //         selectedIndex: navigationShell.currentIndex,
      //         destinations: [
      //           DestinatioinItem(
      //               icon: ScreenTab.myword.icon, label: ScreenTab.myword.label),
      //           DestinatioinItem(
      //               icon: ScreenTab.quiz.icon, label: ScreenTab.quiz.label),
      //           DestinatioinItem(
      //               icon: ScreenTab.search.icon, label: ScreenTab.search.label),
      //           DestinatioinItem(
      //               icon: ScreenTab.ranking.icon,
      //               label: ScreenTab.ranking.label),
      //         ],
      //         onDestinationSelected: (index) {
      //           // if (index > 2) {
      //           //   return;
      //           // }
      //           navigationShell.goBranch(
      //             index,
      //             initialLocation: index == navigationShell.currentIndex,
      //           );
      //         },
      //         onActionButtonSelected: () {
      //           //navigationShell.goBranch(3, initialLocation: false);
      //           print("!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!! CLOSE BUTTON TAPPED");
      //         },
      //       ),
      //     )
      //   ],
      // ),
    );
  }
}

// class MainActivity2 extends StatelessWidget {
//   const MainActivity2({
//     super.key,
//     required this.navigationShell,
//   });

//   final StatefulNavigationShell navigationShell;

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: Text(
//           "My Dic",
//         ),
//         actions: [
//           IconButton(
//               onPressed: () {
//                 context
//                     .push('/${ScreenTab.profile}/${ScreenPage.unAuthorized}');
//               },
//               icon: Icon(Icons.person))
//         ],
//       ),
//       body: navigationShell,
//       bottomNavigationBar: NavigationBar(
//         selectedIndex: navigationShell.currentIndex,
//         destinations: [
//           NavigationDestination(
//               icon: Icon(ScreenTab.myword.icon), label: ScreenTab.myword.label),
//           // NavigationDestination(
//           //     icon: Icon(ScreenTab.note.icon), label: ScreenTab.note.label),
//           NavigationDestination(
//               icon: Icon(ScreenTab.quiz.icon), label: ScreenTab.quiz.label),
//           NavigationDestination(
//               icon: Icon(ScreenTab.search.icon), label: ScreenTab.search.label),
//           NavigationDestination(
//               icon: Icon(ScreenTab.ranking.icon),
//               label: ScreenTab.ranking.label),
//         ],
//         onDestinationSelected: (index) {
//           navigationShell.goBranch(
//             index,
//             initialLocation: index == navigationShell.currentIndex,
//           );
//         },
//       ),
//     );
//   }
// }
