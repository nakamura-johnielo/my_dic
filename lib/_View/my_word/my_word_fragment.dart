import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:my_dic/_Interface_Adapter/ViewModel/my_word_view_model.dart';

class MyWordFragment extends ConsumerWidget {
  const MyWordFragment({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final myWordViewModel = ref.watch(myWordViewModelProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text('My Word'),
      ),
      body: Center(
          child: Column(
        children: [
          Text('This is my word screen'),
          Expanded(
              child: ListView.builder(
            itemCount: myWordViewModel.item.length,
            itemBuilder: (context, index) {
              return ListTile(
                title: Text(myWordViewModel.item[index].word),
                subtitle: Text(myWordViewModel.item[index].word),
              );
            },
          )),
        ],
      )),
    );
  }
}
