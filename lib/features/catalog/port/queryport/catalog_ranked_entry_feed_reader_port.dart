import 'package:my_dic/core/shared/utils/result.dart';
import 'package:my_dic/features/catalog/port/inputdata/catalog_ranked_entry_feed_query.dart';
import 'package:my_dic/features/catalog/port/result/catalog_ranked_entry_feed.dart';

abstract interface class CatalogRankedEntryFeedQueryPort {
  Future<Result<CatalogRankedEntryFeed>> readRankedEntries(
    CatalogRankedEntryFeedQuery query,
  );
}
