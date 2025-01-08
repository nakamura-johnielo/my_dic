import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:my_dic/Constants/tab.dart';
import 'package:my_dic/DI/product.dart';
import 'package:my_dic/_Interface_Adapter/Controller/buffer_controller.dart';
import 'package:my_dic/_Interface_Adapter/ViewModel/search_view_model.dart';

class SearchFragment extends ConsumerWidget {
  SearchFragment({super.key});
  final BufferController _bufferController = DI<BufferController>();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final viewModel = ref.watch(searchViewModelProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text('search'),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              decoration: InputDecoration(
                labelText: 'Search',
                border: OutlineInputBorder(),
              ),
              onChanged: (value) {
                //viewModel.query = value;
                _bufferController.searchWord(value);
              },
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: viewModel.filteredItems.length,
              itemBuilder: (context, index) {
                return ListTile(
                  title: Text(viewModel.filteredItems.isNotEmpty
                      ? viewModel.filteredItems[index].word
                      : 'No data available'),
                  onTap: () {
                    context.push('/${ScreenTab.search}/detail',
                        extra: viewModel.filteredItems[index].wordId);
                  },
                  //title: Text(viewModel.filteredItems[index].word if itemCount!=0 else 'No data available'),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
