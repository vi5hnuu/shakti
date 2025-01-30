
class ResetPassword {
  final String usernameEmail;//autofill this in frontend with username or email used for forgot-password
  final String otp;
  final String password;
  final String confirmPassword;

  const ResetPassword({required this.usernameEmail,required this.otp,required this.password,required this.confirmPassword});

  Map<String,String> toJson() {
    return {
      'usernameEmail':usernameEmail,
      'otp':otp,
      'password':password,
      'confirmPassword':confirmPassword
    };
  }
}