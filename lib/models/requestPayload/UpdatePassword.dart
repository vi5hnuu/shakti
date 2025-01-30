
class UpdatePassword {
  final String otp;
  final String oldPassword;
  final String newPassword;
  final String confirmPassword;

  const UpdatePassword({required this.otp,required this.oldPassword,required this.newPassword,required this.confirmPassword});

  Map<String,dynamic> toJson() {
    return {
      'otp':otp,
      'oldPassword':oldPassword,
      'newPassword':newPassword,
      'confirmPassword':confirmPassword
    };
  }
}
