import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:my_dic/features/quiz/data/data_source/local/json_handler.dart';
import 'package:my_dic/features/quiz/data/repository_impl/json_quiz_repository_impl.dart';
import 'package:my_dic/features/quiz/domain/usecase/english_conj_sub/i_fetch_english_conj_sub_repository.dart';

final jsonHandlerProvider = Provider<JsonHandler>((ref) {
  return JsonHandler();
});

final fetchEnglishConjSubRepositoryProvider =
    Provider<IEnglishConjSubRepository>((ref) {
      return JsonQuizRepositoryImpl( jsonHandler: ref.read(jsonHandlerProvider));
    });
