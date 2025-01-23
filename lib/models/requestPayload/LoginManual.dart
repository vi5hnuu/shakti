
class LoginManual {
  final String usernameEmail;
  final String password;

  const LoginManual({required this.usernameEmail,required this.password});

  Map<String,dynamic> toJson() {
    return {
      'usernameEmail':usernameEmail,
      'password':password
    };
  }
}
