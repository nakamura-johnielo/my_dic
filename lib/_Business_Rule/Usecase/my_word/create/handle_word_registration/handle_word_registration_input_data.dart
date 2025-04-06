class HandleWordRegistrationInputData {
  bool isSuccess;
  void Function() onComplete;
  void Function() onError;
  HandleWordRegistrationInputData(
      this.isSuccess, this.onComplete, this.onError);
}
