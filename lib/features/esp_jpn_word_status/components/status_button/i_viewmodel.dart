
/// ViewModel for EspJpnWordStatus feature
/// Provides unified interface for UI state and commands
abstract class IWordStatusViewModel {

  bool get isLearned ;
  bool get isBookmarked ;
  bool get hasNote ;

  Future<void> toggleLearned() ;
  Future<void> toggleBookmark() ;
  Future<void> toggleHasNote() ;
}
