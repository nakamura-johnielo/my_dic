import 'package:flutter_test/flutter_test.dart';
import 'package:my_dic/features/sync/port/model/remote_mutation.dart';

void main() {
  test('normalizes client time and freezes the field-mask payload', () {
    final fields = <String, Object?>{'isLearned': true};
    final request = RemoteMutationRequest(
      accountId: 'account-1',
      entityId: '42',
      mutationId: 'mutation-1',
      fields: fields,
      fieldMask: fields.keys,
      clientUpdatedAt: DateTime(2026, 8, 7, 12, 0),
      baseRemoteRevision: '3',
    );

    fields['isLearned'] = false;

    expect(request.clientUpdatedAt.isUtc, isTrue);
    expect(request.fields, {'isLearned': true});
    expect(request.fieldMask, ['isLearned']);
    expect(request.baseRemoteRevision, '3');
  });

  test('ack represents all transaction outcomes with remote metadata', () {
    final updatedAt = DateTime.utc(2026, 8, 7, 12, 1);
    const statuses = RemoteMutationAckStatus.values;

    final acks = statuses
        .map((status) => RemoteMutationAck(
              status: status,
              remoteRevision: 4,
              lastMutationId: 'mutation-4',
              serverUpdatedAt: updatedAt,
            ))
        .toList();

    expect(acks.map((ack) => ack.status), statuses);
    expect(acks.every((ack) => ack.remoteRevision == 4), isTrue);
    expect(acks.every((ack) => ack.lastMutationId == 'mutation-4'), isTrue);
    expect(acks.every((ack) => ack.serverUpdatedAt == updatedAt), isTrue);
  });
}
