import 'package:my_dic/core/infrastructure/database/drift/database_provider.dart';
import 'package:my_dic/features/quiz/internal/composition/quiz_composition_factory.dart';
import 'package:my_dic/features/quiz/port/composition_contract.dart';
import 'package:my_dic/features/quiz/port/quiz.dart';

export 'composition_contract.dart';

/// バンドル済み Quiz アセットの未解析テキストを読み込む。
typedef QuizAssetTextLoader = Future<String> Function(String assetPath);

/// Quiz 機能を組み立てるために必要な、アプリ所有のサービス。
final class QuizDependencies {
  const QuizDependencies({
    required this.candidateCatalogGateway,
    required this.gameCatalogGateway,
    required this.database,
    required this.loadAssetText,
  });

  final QuizCandidateCatalogGateway candidateCatalogGateway;
  final QuizGameCatalogGateway gameCatalogGateway;
  final DatabaseProvider database;
  final QuizAssetTextLoader loadAssetText;
}

/// アプリ所有の入力から Quiz の内部ポリシーグラフを組み立てる。
QuizPorts createQuizPorts({required QuizDependencies dependencies}) =>
    createInternalQuizPorts(
      candidateCatalogGateway: dependencies.candidateCatalogGateway,
      gameCatalogGateway: dependencies.gameCatalogGateway,
      database: dependencies.database,
      loadAssetText: dependencies.loadAssetText,
    );
