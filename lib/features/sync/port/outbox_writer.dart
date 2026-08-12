import 'model/sync_mutation.dart';

abstract interface class IOutboxWriter {
  Future<void> enqueue(EnqueueMutation mutation);
}
