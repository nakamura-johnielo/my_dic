abstract interface class SessionFence {
  bool isCurrent({required String accountId, required int sessionEpoch});
}
