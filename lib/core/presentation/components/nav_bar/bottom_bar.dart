// import 'package:flutter/material.dart';
// import 'package:my_dic/core/shared/enums/ui/tab.dart';

// class BottomBar extends StatelessWidget {
//   const BottomBar({
//     super.key,
//     required this.currentIndex,
//     required this.onDestinationSelected,
//     required this.destinations,
//   });

//   final int currentIndex;
//   final ValueChanged<int> onDestinationSelected;
//   final List<NavigationDestination> destinations;

//   @override
//   Widget build(BuildContext context) {
//     return NavigationBar(
//       selectedIndex: navigationShell.currentIndex,
//       destinations: [
//         NavigationDestination(
//             icon: Icon(ScreenTab.myword.icon), label: ScreenTab.myword.label),
//         // NavigationDestination(
//         //     icon: Icon(ScreenTab.note.icon), label: ScreenTab.note.label),
//         NavigationDestination(
//             icon: Icon(ScreenTab.quiz.icon), label: ScreenTab.quiz.label),
//         NavigationDestination(
//             icon: Icon(ScreenTab.search.icon), label: ScreenTab.search.label),
//         NavigationDestination(
//             icon: Icon(ScreenTab.ranking.icon), label: ScreenTab.ranking.label),
//       ],
//       onDestinationSelected: (index) {
//         navigationShell.goBranch(
//           index,
//           initialLocation: index == navigationShell.currentIndex,
//         );
//       },
//     );
//   }

// }




// class StudyBottomBar extends StatelessWidget {
//   const StudyBottomBar({
//     super.key,
//     required this.currentIndex,
//     required this.onDestinationSelected,
//     required this.destinations,
//   });

//   final int currentIndex;
//   final ValueChanged<int> onDestinationSelected;
//   final List<NavigationDestination> destinations;

//   @override
//   Widget build(BuildContext context) {
//     return NavigationBar(
//       selectedIndex: navigationShell.currentIndex,
//       destinations: [
//         NavigationDestination(
//             icon: Icon(ScreenTab.myword.icon), label: ScreenTab.myword.label),
//         // NavigationDestination(
//         //     icon: Icon(ScreenTab.note.icon), label: ScreenTab.note.label),
//         NavigationDestination(
//             icon: Icon(ScreenTab.quiz.icon), label: ScreenTab.quiz.label),
//         NavigationDestination(
//             icon: Icon(ScreenTab.search.icon), label: ScreenTab.search.label),
//         NavigationDestination(
//             icon: Icon(ScreenTab.ranking.icon), label: ScreenTab.ranking.label),
//       ],
//       onDestinationSelected: (index) {
//         navigationShell.goBranch(
//           index,
//           initialLocation: index == navigationShell.currentIndex,
//         );
//       },
//     );
//   }

// }
