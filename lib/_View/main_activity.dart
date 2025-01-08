import 'package:flutter/material.dart';
import 'package:my_dic/Constants/enviroment.dart';
import 'package:my_dic/Constants/screen_tab.dart';
import 'package:my_dic/Provider/bottom_navigation_provider.dart';
import 'package:my_dic/_View/note_fragment.dart';
import 'package:my_dic/_View/ranking_fragment.dart';
import 'package:my_dic/_View/search_fragment.dart';
import 'package:my_dic/_View/word_page_fragment.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/* class MainActivity extends StatefulWidget {
  const MainActivity({super.key, required this.title});
  final String title;

  @override
  State<MainActivity> createState() => _MainActivityState();
} */

class MainActivity extends ConsumerWidget {
  const MainActivity({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentTab = ref.watch(tabIndexProvider);

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(APP_NAME),
      ),
      body: IndexedStack(
        index: currentTab.index,
        children: [
          NoteFragment(),
          SearchFragment(),
          RankingFragment(),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: currentTab.index,
        onTap: (index) {
          // 正しい方法でタブを更新します
          ref.read(tabIndexProvider.notifier).state = ScreenTab.values[index];
        },
        items: ScreenTab.values.map((tab) {
          return BottomNavigationBarItem(
            icon: Icon(
              tab == ScreenTab.search
                  ? Icons.search
                  : tab == ScreenTab.ranking
                      ? Icons.assessment
                      : Icons.note,
            ),
            label: tab.name,
          );
        }).toList(),
      ),
    );
  }
}
