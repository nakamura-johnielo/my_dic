/// 同時にsyncさせないためのシングルフライトコーディネータ
class SingleFlightCoordinator {
  final Set<String> _running = {};
  final Set<String> _rerunRequested = {};

  bool tryAcquire(String accountId) {
    if (_running.add(accountId)) return true;
    _rerunRequested.add(accountId);
    return false;
  }

  bool takeRerunRequest(String accountId) => _rerunRequested.remove(accountId);

  void release(String accountId) {
    _running.remove(accountId);
    _rerunRequested.remove(accountId);
  }
}
