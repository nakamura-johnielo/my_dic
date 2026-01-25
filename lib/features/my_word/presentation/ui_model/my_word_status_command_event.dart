sealed class MyWordStatusCommandEvent {}

class ToggleLearnedSucceeded extends MyWordStatusCommandEvent {}
class ToggleLearnedFailed extends MyWordStatusCommandEvent {}

class ToggleBookmarkedSucceeded extends MyWordStatusCommandEvent {}
class ToggleBookmarkedFailed extends MyWordStatusCommandEvent {}