import 'model/remote_mutation.dart';

/// Identifies a dataset's stable remote wire mapping without exposing an SDK
/// document reference to feature code.
enum RemoteMutationTarget {
  myWord,
  myWordStatus,
  userProfile,
  espJpnWordStatus,
  jpnEspWordStatus,
}

/// Executes a pure remote mutation request against the application's remote
/// backend. SDK transaction and value mapping are owned by the implementation.
abstract interface class RemoteMutationExecutor {
  Future<RemoteMutationAck> execute({
    required RemoteMutationTarget target,
    required RemoteMutationRequest request,
  });

  Future<RemoteUserProfileProvisioningResult> provisionUserProfile(
    RemoteUserProfileProvisioningRequest request,
  );
}
