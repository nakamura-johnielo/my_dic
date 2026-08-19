class LocalUserDTO {
  final String deviceId;

  // TODO: createdAt を追加

  LocalUserDTO({required this.deviceId});
  LocalUserDTO copyWith({String? deviceId}) {
    return LocalUserDTO(
      deviceId: deviceId ?? this.deviceId,
    );
  }
}
