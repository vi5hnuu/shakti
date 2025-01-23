import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shakti/state/auth/Auth_bloc.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  late final authBloc=BlocProvider.of<AuthBloc>(context);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(child: Center(child: Column(
        children: [
          FilledButton(onPressed: () => authBloc.add(LogoutEvent()), child: Text("Logout"))
        ],
      ))),
    );
  }
}
