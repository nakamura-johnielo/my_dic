import 'package:flutter_riverpod/flutter_riverpod.dart';

// プロバイダーの宣言
final counterProvider = StateProvider<int>((ref) => 0);
