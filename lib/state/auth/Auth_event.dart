part of 'Auth_bloc.dart';

@immutable
abstract class AuthEvent {
  final CancelToken? cancelToken;
  const AuthEvent({this.cancelToken});
}

class ExpireHttpState extends AuthEvent{
  final String forr;
  const ExpireHttpState({required this.forr});
}

class TryAuthenticatingEvent extends AuthEvent{
  const TryAuthenticatingEvent({super.cancelToken});
}

class LoginEvent extends AuthEvent {
  final String usernameEmail;
  final String password;

  const LoginEvent({required this.usernameEmail, required this.password, CancelToken? cancelToken}) : super(cancelToken: cancelToken);
}

class GoogleLoginEvent extends AuthEvent{
  final String idToken;

  const GoogleLoginEvent({required this.idToken,super.cancelToken});
}

class JwtVerifyEvent extends AuthEvent{
  final String idToken;

  const JwtVerifyEvent({required this.idToken,super.cancelToken});
}

class RegisterEvent extends AuthEvent {
  final String firstName;
  final String lastName;
  final String username;
  final String email;
  final String password;

  const RegisterEvent(
      {required this.firstName,
        required this.lastName,
        required this.username,
        required this.email,
        required this.password,
        CancelToken? cancelToken})
      : super(cancelToken: cancelToken);
}

class FetchMeInfoEvent extends AuthEvent {
  const FetchMeInfoEvent({CancelToken? cancelToken}) : super(cancelToken: cancelToken);
}

class LogoutEvent extends AuthEvent {
  const LogoutEvent({CancelToken? cancelToken}) : super(cancelToken: cancelToken);
}

class ReVerifyEvent extends AuthEvent {
  final String email;
  const ReVerifyEvent({required String this.email, CancelToken? cancelToken});
}

class ForgotPasswordEvent extends AuthEvent {
  final String usernameEmail;
  const ForgotPasswordEvent({required this.usernameEmail, CancelToken? cancelToken});
}

class ResetPasswordEvent extends AuthEvent {
  final String usernameEmail;
  final String otp;
  final String password;
  final String confirmPassword;

  const ResetPasswordEvent({required this.usernameEmail, required this.otp, required this.password, required this.confirmPassword, CancelToken? cancelToken});
}

class UpdateProfilePic extends AuthEvent {
  final MultipartFile profileImage;
  const UpdateProfilePic({required this.profileImage, CancelToken? cancelToken});
}

class UpdatePosterPicEvent extends AuthEvent {
  final MultipartFile posterImage;
  const UpdatePosterPicEvent({required this.posterImage, CancelToken? cancelToken});
}

class DeleteMeEvent extends AuthEvent {
  const DeleteMeEvent({CancelToken? cancelToken});
}

class UpdatePasswordInitEvent extends AuthEvent {
  final String usernameEmail;

  const UpdatePasswordInitEvent({required this.usernameEmail,CancelToken? cancelToken});
}

class UpdatePasswordCompleteEvent extends AuthEvent {
  final String otp;
  final String oldPassword;
  final String newPassword;
  final String confirmPassword;

  const UpdatePasswordCompleteEvent({required this.otp,required this.oldPassword, required this.newPassword, required this.confirmPassword, CancelToken? cancelToken});
}
