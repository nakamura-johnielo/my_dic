import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:my_dic/DI/product.dart';
import 'package:my_dic/features/search/presentation/view_model/buffer_controller.dart';
import 'package:my_dic/features/search/presentation/view_model/search_view_model.dart';

final searchViewModelProvider = ChangeNotifierProvider<SearchViewModel>((ref) {
  return SearchViewModel();
});

final bufferControllerProvider = Provider<BufferController>((ref) {
  return BufferController(
    ref.read(searchWordUseCaseProvider),
    ref.read(judgeSearchWordUseCaseProvider),
  );
});
