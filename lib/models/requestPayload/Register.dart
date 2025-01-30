class Register {
   final String firstName;
   final String lastName;
   final String userName;
   final String email;
   final String password;

   const Register({required this.firstName,required this.lastName,required this.userName,required this.email,required this.password});

  Map<String,String> toJson() {
     return {
        'firstName':firstName,
        'lastName':lastName,
        'userName':userName,
        'email':email,
        'password':password
     };
  }
}


