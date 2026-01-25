
sealed class WordStatusCommandEvent {
  const WordStatusCommandEvent();
}

class ToggleLearnedSucceeded extends WordStatusCommandEvent {}
class ToggleLearnedFailed extends WordStatusCommandEvent {}

class ToggleBookmarkedSucceeded extends WordStatusCommandEvent {}
class ToggleBookmarkedFailed extends WordStatusCommandEvent {}

class ToggleNoteSucceeded extends WordStatusCommandEvent {}
class ToggleNoteFailed extends WordStatusCommandEvent {}