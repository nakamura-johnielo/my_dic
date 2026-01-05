import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

// final sharedPreferencesProvider = FutureProvider<SharedPreferences>((_) {
//   return SharedPreferences.getInstance();
// });


final sharedPreferencesProvider = Provider<SharedPreferences>((ref) {
  throw UnimplementedError('sharedPreferencesProvider must be overridden in main()');
});