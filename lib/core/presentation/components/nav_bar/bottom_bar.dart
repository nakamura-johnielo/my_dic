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
//             icon: Icon(MainScreenTab.myword.icon), label: MainScreenTab.myword.label),
//         // NavigationDestination(
//         //     icon: Icon(MainScreenTab.note.icon), label: MainScreenTab.note.label),
//         NavigationDestination(
//             icon: Icon(MainScreenTab.quiz.icon), label: MainScreenTab.quiz.label),
//         NavigationDestination(
//             icon: Icon(MainScreenTab.search.icon), label: MainScreenTab.search.label),
//         NavigationDestination(
//             icon: Icon(MainScreenTab.ranking.icon), label: MainScreenTab.ranking.label),
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
//             icon: Icon(MainScreenTab.myword.icon), label: MainScreenTab.myword.label),
//         // NavigationDestination(
//         //     icon: Icon(MainScreenTab.note.icon), label: MainScreenTab.note.label),
//         NavigationDestination(
//             icon: Icon(MainScreenTab.quiz.icon), label: MainScreenTab.quiz.label),
//         NavigationDestination(
//             icon: Icon(MainScreenTab.search.icon), label: MainScreenTab.search.label),
//         NavigationDestination(
//             icon: Icon(MainScreenTab.ranking.icon), label: MainScreenTab.ranking.label),
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
