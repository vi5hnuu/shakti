import 'dart:async';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:logger/logger.dart';
import 'sign_in_button.dart';

const List<String> scopes = <String>[
  "openid"
];

GoogleSignIn _googleSignIn = GoogleSignIn(
  scopes: scopes,
);

void main() {
  runApp(
    const MaterialApp(
      title: 'Google Sign In',
      home: SignInDemo(),
    ),
  );
}

/// The SignInDemo app.
class SignInDemo extends StatefulWidget {
  const SignInDemo({super.key});

  @override
  State createState() => _SignInDemoState();
}

class _SignInDemoState extends State<SignInDemo> {
  GoogleSignInAccount? _currentUser;

  @override
  void initState() {
    super.initState();

    _googleSignIn.onCurrentUserChanged
        .listen((GoogleSignInAccount? account) async {
      setState(() =>_currentUser = account);
    });
  }

  Future<void> _handleSignIn() async {
    try {
      final data=await _googleSignIn.signIn();
      final auth=await data?.authentication;
      _revokeAccess();
      print(auth);
    } catch (error) {
      print(error);
    }
  }

  Future<void> _handleSignOut() => _googleSignIn.disconnect();

  Widget _buildBody() {
    final GoogleSignInAccount? user = _currentUser;
    if (user != null) {
      // The user is Authenticated
      return Column(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: <Widget>[
          ListTile(
            leading: GoogleUserCircleAvatar(
              identity: user,
            ),
            title: Text(user.displayName ?? ''),
            subtitle: Text(user.email),
          ),
          const Text('Signed in successfully.'),
          ElevatedButton(
            onPressed: _handleSignOut,
            child: const Text('SIGN OUT'),
          ),
        ],
      );
    } else {
      // The user is NOT Authenticated
      return Column(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: <Widget>[
          const Text('You are not currently signed in.'),
          // This method is used to separate mobile from web code with conditional exports.
          // See: src/sign_in_button.dart
          buildSignInButton(
            onPressed: _handleSignIn,
          ),
        ],
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text('Google Sign In'),
        ),
        body: ConstrainedBox(
          constraints: const BoxConstraints.expand(),
          child: _buildBody(),
        ));
  }

  Future<void> _revokeAccess() async {
    try {
      final auth = await _googleSignIn.currentUser?.authentication;
      if(auth==null) return;
      final accessToken = auth.accessToken;

      // Revoke the access token
      final response = await Dio().post('https://oauth2.googleapis.com/revoke',
          data: {'token': accessToken},
          options: Options(headers: {'Content-Type': 'application/x-www-form-urlencoded'},)
      );

      if (response.statusCode == 200) {
        print('Access token revoked successfully');
      } else {
        print('Failed to revoke access token: ${response.data}');
      }
    } catch (e) {
      print('Error revoking access: $e');
    }
  }
}