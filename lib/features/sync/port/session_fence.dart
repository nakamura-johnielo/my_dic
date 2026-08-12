abstract interface class ISessionFence {
  bool isCurrent({required String accountId, required int sessionEpoch});
}
