import 'package:my_dic/core/shared/enums/ui/button_status.dart';

class UserProfileUIState {
  final ButtonStatus savingButtonStatus;
  final String? errorMessage;

  UserProfileUIState(
      {this.savingButtonStatus = ButtonStatus.normal, this.errorMessage});

  UserProfileUIState copyWith({
    ButtonStatus? savingButtonStatus,
    String? errorMessage,
  }) {
    return UserProfileUIState(
      savingButtonStatus: savingButtonStatus ?? this.savingButtonStatus,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }
}
