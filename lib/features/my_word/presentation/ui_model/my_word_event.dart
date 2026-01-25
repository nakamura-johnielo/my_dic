sealed class MyWordCommandEvent {}

class DeleteSucceeded extends MyWordCommandEvent {}
class DeleteFailed extends MyWordCommandEvent {}

class UpdateSucceeded extends MyWordCommandEvent {}
class UpdateFailed extends MyWordCommandEvent {}