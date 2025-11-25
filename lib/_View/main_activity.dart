import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:my_dic/Constants/tab.dart';
//import 'package:my_dic/Constants/screen_tab.dart';

class MainActivity extends StatelessWidget {
  const MainActivity({
    super.key,
    required this.navigationShell,
  });

  final StatefulNavigationShell navigationShell;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
      bottomNavigationBar: NavigationBar(
        selectedIndex: navigationShell.currentIndex,
        destinations: [
          NavigationDestination(
              icon: Icon(ScreenTab.myword.icon), label: ScreenTab.myword.label),
          // NavigationDestination(
          //     icon: Icon(ScreenTab.note.icon), label: ScreenTab.note.label),
          NavigationDestination(
              icon: Icon(ScreenTab.quiz.icon), label: ScreenTab.quiz.label),
          NavigationDestination(
              icon: Icon(ScreenTab.search.icon), label: ScreenTab.search.label),
          NavigationDestination(
              icon: Icon(ScreenTab.ranking.icon),
              label: ScreenTab.ranking.label),
        ],
        onDestinationSelected: (index) {
          navigationShell.goBranch(
            index,
            initialLocation: index == navigationShell.currentIndex,
          );
        },
      ),
    );
  }
}
