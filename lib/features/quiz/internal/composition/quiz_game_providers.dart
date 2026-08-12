import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:my_dic/features/catalog/port/presentation_dependencies.dart';
import 'package:my_dic/features/quiz/internal/application/load_quiz_game_compatibility_adapter.dart';
import 'package:my_dic/features/quiz/internal/game/composition/data_di.dart';
import 'package:my_dic/features/quiz/internal/infrastructure/assets/quiz_game_assets.dart';
import 'package:my_dic/features/quiz/port/game_loader.dart';
import 'package:my_dic/features/quiz/port/model/quiz_game_load_result.dart';
import 'package:my_dic/features/quiz/port/model/quiz_game_query.dart';

final loadQuizGameProvider =
    Provider<LoadQuizGame>((ref) => LoadQuizGameCompatibilityAdapter(
          catalogReaderPort: ref.read(catalogReaderPortDependencyProvider),
          conjugationReaderPort:
              ref.read(conjugationReaderPortDependencyProvider),
          englishConjugationRepository:
              ref.read(esEnConjugacionRepositoryProvider),
          assets: QuizGameAssets(),
        ));

final quizGameLoadProvider =
    FutureProvider.autoDispose.family<QuizGameLoadResult, QuizGameQuery>(
  (ref, query) => ref.read(loadQuizGameProvider).load(query),
);
