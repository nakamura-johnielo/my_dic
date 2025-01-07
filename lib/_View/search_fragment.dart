import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:my_dic/DI/product.dart';
import 'package:my_dic/_Interface_Adapter/Controller/buffer_controller.dart';
import 'package:my_dic/_Interface_Adapter/ViewModel/search_view_model.dart';

/* /// ViewModelをプロバイダーで提供
final searchViewModelProvider =
    ChangeNotifierProvider((ref) => SearchViewModel());

class SearchViewModel extends ChangeNotifier {
  final List<String> _items = [
    /* "Apple",
    "Banana",
    "Cherry",
    "Date",
    "Elderberry",
    "Fig",
    "Grape",
    "Guava", */
  ];
  String _query = "";

  // 検索クエリの取得と更新
  String get query => _query;
  set query(String value) {
    _query = value;
    notifyListeners();
  }

  // フィルタリングされたアイテムの取得
  List<String> get filteredItems {
    if (_query.isEmpty) {
      return _items;
    }
    return _items
        .where((item) => item.toLowerCase().contains(_query.toLowerCase()))
        .toList();
  }
} */

class SearchFragment extends ConsumerWidget {
  SearchFragment({super.key});
  final BufferController _bufferController = DI<BufferController>();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final viewModel = ref.watch(searchViewModelProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text('ViewModel Example'),
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
