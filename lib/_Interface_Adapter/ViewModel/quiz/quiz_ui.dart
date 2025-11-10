import 'package:flutter_riverpod/flutter_riverpod.dart';
// ...existing code...

/// クイズ用検索クエリのプロバイダー
final quizSearchQueryProvider = StateProvider<String>((ref) => '');
