import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:my_dic/core/di/router/router.dart';
import 'package:my_dic/core/di/ui/ui_di.dart';
import 'package:my_dic/core/presentation/components/nav_bar/item.dart';
import 'package:my_dic/core/presentation/components/nav_bar/studay_bottom_bar.dart';
import 'package:my_dic/core/shared/consts/ui/ui.dart';
import 'package:my_dic/core/shared/enums/entry_point.dart';
import 'package:my_dic/core/shared/consts/ui/tab.dart';
import 'package:my_dic/router/navigator_service.dart';
import 'package:my_dic/router/route_names.dart';
//import 'package:my_dic/Constants/screen_tab.dart';

class MainActivity extends ConsumerWidget {
  const MainActivity({
    super.key,
    required this.navigationShell,
  });

  final StatefulNavigationShell navigationShell;

  DestinatioinItem _buildDestinatioinItem(ScreenTabBehaivor tab) {
    return DestinatioinItem(icon: tab.icon, label: tab.label);
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    int _getDestinationShellIndex(index, changeBranch) {
      final entryPoint = ref.read(entryPointProvider);
      if (changeBranch) {
        print("move index: ${ref.read(lastStudyBranchTabIndexProvider)}");
        index = ref.read(lastStudyBranchTabIndexProvider);
      }

      if (entryPoint.category == EntryPointCategory.study) {
        return index + 2;
      }
      return index == 2 ? ref.read(lastStudyBranchTabIndexProvider) : index;
    }

    int _navBarPhantomIndex(shellIndex) {
      final entryPoint = ref.read(entryPointProvider);
      if (entryPoint.category == EntryPointCategory.study) {
        return shellIndex - 2;
      }
      return shellIndex; // == 2 ? ref.read(lastStudyBranchIndexProvider) : shellIndex;
    }

//  final double bottomBarHeight = UIConsts.bottomBarHeight + MediaQuery.of(context).padding.bottom;

    // ref.read(bottomBarHeightProvider.notifier).setHeight( bottomBarHeight);
    final entryPoint = ref.read(entryPointProvider);
    return Scaffold(
      extendBody: true,
      appBar: AppBar(
        title: Text(
          "My Dic",
        ),
        actions: [
          IconButton(
              onPressed: () {
                // context.push(
                //     '/${MetaScreenTab.profile}/${MetaScreenPage.unAuthorized}');
                context.pushNamed(RouteNames.profile);
              },
              icon: Icon(Icons.person))
        ],
      ),

      body: navigationShell,

      bottomNavigationBar: SwitchableFloatBottomBar(
        entryPoint: entryPoint,
        selectedIndex: _navBarPhantomIndex(navigationShell.currentIndex),
        destinationMap: {
          EntryPointCategory.main:
              MainScreenTab.values.map(_buildDestinatioinItem).toList(),
          //  [
          //   _buildDestinatioinItem(MainScreenTab.myword),
          //   _buildDestinatioinItem(MainScreenTab.search),
          //   _buildDestinatioinItem(MainScreenTab.study),
          // ],
          EntryPointCategory.study:
              StudyScreenTab.values.map(_buildDestinatioinItem).toList(),
          // [
          //   _buildDestinatioinItem(StudyScreenTab.dashboard),
          //   _buildDestinatioinItem(StudyScreenTab.ranking),
          //   _buildDestinatioinItem(StudyScreenTab.quiz),
          // ],

          // _buildDestinatioinItem2(StudyScreenTab.dashboard),
          // _buildDestinatioinItem2(StudyScreenTab.ranking),
          // _buildDestinatioinItem2(StudyScreenTab.quiz),
        },
        onDestinationSelected: (tabIndex) {
          if (tabIndex == _navBarPhantomIndex(navigationShell.currentIndex)) {
            print("00000000000000000000000000000");
            ref
                .read(appNavigatorServiceProvider)
                .clearCurrentBranchHistoryAndGoRoot();
            return;
          }
          final entryPoint = ref.read(entryPointProvider);
          print("||||||||||||||||||||entrypoint current: $entryPoint");

          if (entryPoint.category == EntryPointCategory.study) {
            // Study内のタブ切り替え
            print(
                "study ||||||||||||||||||||entrypoint move: ${StudyScreenTab.values[tabIndex].entryPoint}");
            ref.read(entryPointProvider.notifier).state =
                StudyScreenTab.values[tabIndex].entryPoint;

            ref.read(lastStudyBranchTabIndexProvider.notifier).state = tabIndex;

            // Study内のStatefulNavigationShellを取得して切り替え
            // final nestedShell = navigationShell;
            // ネストしたShell内のタブを切り替え
            navigationShell.goBranch(
              _getDestinationShellIndex(tabIndex, false),
              initialLocation:
                  false, //tabIndex == navigationShell.currentIndex,
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
            print(
                "main ||||||||||||||||||||entrypoint move: ${nextEntryPoint}");

            // final activeIndex=ref.read(lastMainBranchIndexProvider);
            navigationShell.goBranch(
              _getDestinationShellIndex(
                  tabIndex, nextEntryPoint.category != EntryPointCategory.main),
              initialLocation: tabIndex == navigationShell.currentIndex,
            );
          }
        },
        // onDestinationSelected: (index) {
        //   //entry point 設定
        //   // ref.read(entryPointProvider.notifier).state =
        //   //     MainScreenTab.values[index].entryPoint;
        //   final entryPoint = ref.read(entryPointProvider);
        //   print("||||||||||||||||||||entrypoint current: $entryPoint");

        //   if (entryPoint.category == EntryPointCategory.study) {
        //   print("study ||||||||||||||||||||entrypoint move: ${StudyScreenTab.values[index].entryPoint}");
        //     ref.read(entryPointProvider.notifier).state =
        //         StudyScreenTab.values[index].entryPoint;
        //   } else {
        //      print("main ||||||||||||||||||||entrypoint move: ${MainScreenTab.values[index].entryPoint}");

        //     ref.read(entryPointProvider.notifier).state =
        //         MainScreenTab.values[index].entryPoint;
        //   }

        //   // if (MainScreenTab.values[index] == MainScreenTab.study) {
        //   //   ref.read(entryPointProvider.notifier).state =
        //   //       EntryPoint.studyRanking;
        //   // }
        //   // if (MainScreenTab.values[index] == MainScreenTab.study) {
        //   //   ref.read(entryPointProvider.notifier).state =
        //   //       EntryPoint.studyRanking;
        //   // } else {
        //   // }

        //   //body切り替え
        //   navigationShell.goBranch(
        //     index,
        //     initialLocation: index == navigationShell.currentIndex,
        //   );
        // },
        onActionButtonSelected: () {
          //navigationShell.goBranch(3, initialLocation: false);
          print("!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!! CLOSE BUTTON TAPPED");
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
          navigationShell.goBranch(
            ref.read(lastMainBranchIndexProvider),
            //initialLocation: index == navigationShell.currentIndex,
          );
        },
      ),

      // FloatBottomBar(
      //   selectedIndex: navigationShell.currentIndex,
      //   destinations: [
      //     _buildDestinatioinItem(MainScreenTab.myword),
      //     _buildDestinatioinItem(MainScreenTab.search),
      //     _buildDestinatioinItem(MainScreenTab.study),

      //     // _buildDestinatioinItem2(StudyScreenTab.dashboard),
      //     // _buildDestinatioinItem2(StudyScreenTab.ranking),
      //     // _buildDestinatioinItem2(StudyScreenTab.quiz),
      //   ],
      //   onDestinationSelected: (index) {
      //     //entry point 設定
      //     ref.read(entryPointProvider.notifier).state =
      //         MainScreenTab.values[index].entryPoint;

      //     //body切り替え
      //     navigationShell.goBranch(
      //       index,
      //       initialLocation: index == navigationShell.currentIndex,
      //     );
      //   },
      //   onActionButtonSelected: () {
      //     //navigationShell.goBranch(3, initialLocation: false);
      //     print("!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!! CLOSE BUTTON TAPPED");
      //   },
      // ),

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
      //               icon: MainScreenTab.myword.icon, label: MainScreenTab.myword.label),
      //           DestinatioinItem(
      //               icon: MainScreenTab.quiz.icon, label: MainScreenTab.quiz.label),
      //           DestinatioinItem(
      //               icon: MainScreenTab.search.icon, label: MainScreenTab.search.label),
      //           DestinatioinItem(
      //               icon: MainScreenTab.ranking.icon,
      //               label: MainScreenTab.ranking.label),
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
//                     .push('/${MetaScreenTab.profile}/${ScreenPage.unAuthorized}');
//               },
//               icon: Icon(Icons.person))
//         ],
//       ),
//       body: navigationShell,
//       bottomNavigationBar: NavigationBar(
//         selectedIndex: navigationShell.currentIndex,
//         destinations: [
//           NavigationDestination(
//               icon: Icon(MainScreenTab.myword.icon), label: MainScreenTab.myword.label),
//           // NavigationDestination(
//           //     icon: Icon(MainScreenTab.note.icon), label: MainScreenTab.note.label),
//           NavigationDestination(
//               icon: Icon(MainScreenTab.quiz.icon), label: MainScreenTab.quiz.label),
//           NavigationDestination(
//               icon: Icon(MainScreenTab.search.icon), label: MainScreenTab.search.label),
//           NavigationDestination(
//               icon: Icon(MainScreenTab.ranking.icon),
//               label: MainScreenTab.ranking.label),
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
