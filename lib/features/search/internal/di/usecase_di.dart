import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:my_dic/features/search/port/reader.dart';
import 'package:my_dic/features/search/port/presentation_dependencies.dart';

final searchWordUseCaseProvider = Provider<SearchReaderPort>(
    (ref) => ref.read(searchReaderPortDependencyProvider));
