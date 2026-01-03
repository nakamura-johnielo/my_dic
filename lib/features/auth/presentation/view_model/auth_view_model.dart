// import 'package:flutter_riverpod/flutter_riverpod.dart';
// import 'package:my_dic/core/shared/utils/result.dart';
// import 'package:my_dic/features/auth/domain/usecase/i_send_email_use_case.dart';
// import 'package:my_dic/features/auth/domain/usecase/i_sign_in_use_case.dart';
// import 'package:my_dic/features/auth/domain/usecase/i_sign_out_use_case.dart';
// import 'package:my_dic/features/auth/domain/usecase/i_sign_up_use_case.dart';
// import 'package:my_dic/features/auth/domain/usecase/i_verify_email_use_case.dart';
// import 'package:my_dic/core/domain/entity/auth.dart';
// import 'package:my_dic/features/user/presentation/model/user_ui_model.dart';

// class AuthViewModel extends StateNotifier<UserState?> {
//   final ISignInUseCase _signInInteractor;
//   final ISignUpUseCase _signUpInteractor;
//   final IVerifyEmailUseCase _verficateInteractor;
//   final ISignOutUseCase _signOutInteractor;
//   final IResetEmailPasswordUseCase _resetEPasswordUseCase;

//   AuthViewModel(this._signInInteractor, this._signUpInteractor,
//       this._verficateInteractor, this._signOutInteractor,this._resetEPasswordUseCase)
//       : super(null);

//   void setAuthInfo(AppAuth appAuth) {
//     state = state?.copyWith(
//       id: appAuth.userId,
//       email: appAuth.email,
//       isAuthorized: appAuth.isVerified,
//     );
//   }


//   Future<String> signOut() async {
//     final result = await _signOutInteractor.execute();
//     return result.when(
//       success: (_) => 'ログアウトしました',
//       failure: (error) => 'ログアウトに失敗しました: ${error.message}',
//     );
//   }

//   Future<String> verifyEmail() async {
//     final result = await _verficateInteractor.execute();
//     return result.when(
//       success: (_) => '確認メールを送信しました',
//       failure: (error) => '送信に失敗しました: ${error.message}',
//     );
//   }

//   Future<String> resetEmailPassword(String email) async {
//     final result = await _resetEPasswordUseCase.execute(email);
//     return result.when(
//       success: (_) => 'リセット用メールを送信しました',
//       failure: (error) => '送信に失敗しました: ${error.message}',
//     );
//   }

//   Future<String> signIn(String email, String password) async {
//     final result = await _signInInteractor.execute(email, password);

//     return result.when(
//       success: (authEntity) async {
//         if (!authEntity.isVerified) {
//           final verifyResult = await _verficateInteractor.execute();
//           return verifyResult.when(
//             success: (_) => '確認メールを送信しました',
//             failure: (error) => 'ログイン成功しましたが、確認メールの送信に失敗しました',
//           );
//         } else {
//           print("**********signin success**********");
//           state = state?.copyWith(
//             id: authEntity.userId,
//             email: authEntity.email,
//             isAuthorized: authEntity.isVerified,
//           );
//           return 'ログインに成功しました';
//         }
//       },
//       failure: (error) => error.message,
//     );
//   }

//   Future<String> signUp(String email, String password) async {
//     final result = await _signUpInteractor.execute(email, password);

//     return result.when(
//       success: (appAuth) async {
//         if (!appAuth.isVerified) {
//           final verifyResult = await _verficateInteractor.execute();
//           return verifyResult.when(
//             success: (_) => '確認メールを送信しました',
//             failure: (error) => 'アカウント作成に成功しましたが、確認メールの送信に失敗しました',
//           );
//         } else {
//           return 'アカウント作成に成功しました';
//         }
//       },
//       failure: (error) => error.message,
//     );
//   }
// }
