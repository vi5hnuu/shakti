import 'package:animated_text_kit/animated_text_kit.dart';
import 'package:dio/dio.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:shakti/routes.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:go_router/go_router.dart';
import 'package:shakti/singletons/DioSingleton.dart';
import 'package:shakti/singletons/LoggerSingleton.dart';
import 'package:shakti/singletons/NotificationService.dart';
import 'package:shakti/singletons/SecureStorage.dart';
import 'package:shakti/widgets/CustomElevatedButton.dart';

import '../../state/auth/Auth_bloc.dart';
import '../../state/httpStates.dart';


const List<String> scopes = <String>[
  "openid"
];

final GoogleSignIn _googleSignIn = GoogleSignIn(
  scopes: scopes,
);

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  GoogleSignInAccount? _currentUser;
  late final authBloc=BlocProvider.of<AuthBloc>(context);
  late final router=GoRouter.of(context);
  final usernameEmailC=TextEditingController();
  final passwordC=TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: BlocConsumer<AuthBloc,AuthState>(
              listenWhen: (previous, current) => previous!=current,
              listener: (context, state) {
                final error=state.getAnyError(forr: [HttpStates.CUSTOM_LOGIN,HttpStates.GOOGLE_LOGIN]);
                if(error!=null){
                  NotificationService.showSnackbar(text: error,color: Colors.red);
                }else if(state.anyDone(forr:[HttpStates.CUSTOM_LOGIN,HttpStates.GOOGLE_LOGIN])){
                  router.goNamed(AppRoutes.home.name);
                }
              },
              buildWhen: (previous, current) => previous!=current,
              builder: (context, state) {
                return Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  mainAxisSize: MainAxisSize.max,
                  children: [
                    SizedBox(
                      height: 32,
                      child: DefaultTextStyle(
                        style: const TextStyle(
                            fontSize: 28.0,
                            fontFamily: 'oxanium',
                            color: Colors.red,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 1.5
                        ),
                        softWrap: true,
                        textHeightBehavior: TextHeightBehavior(),
                        child: AnimatedTextKit(
                          repeatForever: true,
                          animatedTexts: [
                            FadeAnimatedText('Welcome'),
                            FadeAnimatedText('to'),
                            FadeAnimatedText('Your Spiritual Journey!',duration: Duration(seconds: 3)),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                    TextFormField(controller: usernameEmailC,maxLines: 1,decoration: InputDecoration(labelText: "Username/Email",border: OutlineInputBorder(borderRadius: BorderRadius.circular(6)))),
                    const SizedBox(height: 8),
                    TextFormField(controller: passwordC,maxLines: 1,obscureText: true,obscuringCharacter: "*",decoration: InputDecoration(labelText: "Password",border: OutlineInputBorder(borderRadius: BorderRadius.circular(6)))),
                    const SizedBox(height: 16),
                    CustomElevatedButton(onPressed: () => authBloc.add(LoginEvent(usernameEmail: usernameEmailC.text, password: passwordC.text)),
                        child:  Text("Log In",style: TextStyle(color: Colors.white))),
                    CustomElevatedButton(onPressed: _loginViaGoogle, child:  Row(
                      mainAxisAlignment: MainAxisAlignment.center
                      ,children: [
                      Icon(FontAwesomeIcons.google,color: Colors.white,),
                      const SizedBox(width: 12,),
                      Text("Sign In",style: TextStyle(color: Colors.white))
                    ],)),
                    CustomElevatedButton(onPressed: () => router.pushNamed(AppRoutes.resetPasswordInit.name),
                        child:  Row(
                          mainAxisAlignment: MainAxisAlignment.center
                          ,children: [
                          Icon(FontAwesomeIcons.key,color: Colors.white),
                          const SizedBox(width: 12,),
                          Text("Forgot Password",style: TextStyle(color: Colors.white),)
                        ],))
                  ],
                );
              },
            ),
          )),
    );
  }

  void _loginViaGoogle() async {
    try {
      final data = await _googleSignIn.signIn();
      final auth = await data?.authentication;
      _revokeGoogleAccessToken();
      if(auth?.idToken==null) throw Exception("Failed to login via google");
      authBloc.add(GoogleLoginEvent(idToken: auth!.idToken!));
    } catch (error) {
      NotificationService.showSnackbar(text: error.toString(),color: Colors.red);
    }
  }

  Future<void> _revokeGoogleAccessToken() async {
    try {
      final auth = await _googleSignIn.currentUser?.authentication;
      if(auth==null) return;
      final accessToken = auth.accessToken;

      // Revoke the access token
      final response = await DioSingleton().dio.post('https://oauth2.googleapis.com/revoke',
          data: {'token': accessToken},
          options: Options(headers: {'Content-Type': 'application/x-www-form-urlencoded'},)
      );

      if (response.statusCode == 200) {
        LoggerSingleton().logger.i('Access token revoked successfully');
      } else {
        LoggerSingleton().logger.e('Failed to revoke access token: ${response.data}');
      }
    } catch (e) {
      LoggerSingleton().logger.e('Error revoking access: $e');
    }
  }

  @override
  void dispose() {
    super.dispose();
  }
}

//   Future<void> _handleSignIn() async {
//     try {
//       final data=await _googleSignIn.signIn();
//       final auth=await data?.authentication;
//       _revokeAccess();
//       print(auth);
//     } catch (error) {
//       print(error);
//     }
//   }
//
//   Future<void> _handleSignOut() => _googleSignIn.disconnect();
//
//   Widget _buildBody() {
//     final GoogleSignInAccount? user = _currentUser;
//     if (user != null) {
//       // The user is Authenticated
//       return Column(
//         mainAxisAlignment: MainAxisAlignment.spaceAround,
//         children: <Widget>[
//           ListTile(
//             leading: GoogleUserCircleAvatar(
//               identity: user,
//             ),
//             title: Text(user.displayName ?? ''),
//             subtitle: Text(user.email),
//           ),
//           const Text('Signed in successfully.'),
//           ElevatedButton(
//             onPressed: _handleSignOut,
//             child: const Text('SIGN OUT'),
//           ),
//         ],
//       );
//     } else {
//       // The user is NOT Authenticated
//       return Column(
//         mainAxisAlignment: MainAxisAlignment.spaceAround,
//         children: <Widget>[
//           const Text('You are not currently signed in.'),
//           // This method is used to separate mobile from web code with conditional exports.
//           // See: src/sign_in_button.dart
//           buildSignInButton(
//             onPressed: _handleSignIn,
//           ),
//         ],
//       );
//     }
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//         appBar: AppBar(
//           title: const Text('Google Sign In'),
//         ),
//         body: ConstrainedBox(
//           constraints: const BoxConstraints.expand(),
//           child: _buildBody(),
//         ));
//   }
//

// }

