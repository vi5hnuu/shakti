import 'package:shakti/models/enums/UserRole.dart';

class UpdatePassword {
  final String otp;
  final String oldPassword;
  final String newPassword;
  final String confirmPassword;

  const UpdatePassword({required this.otp,required this.oldPassword,required this.newPassword,required this.confirmPassword});
}
