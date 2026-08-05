import 'package:my_dic/features/sync/application/model/sync_mutation.dart';

abstract interface class OutboxWriter {
  Future<void> enqueue(EnqueueMutation mutation);
}
