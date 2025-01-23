import 'dart:async';
import 'dart:convert';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:shakti/routes.dart';
import 'package:shakti/singletons/LoggerSingleton.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:go_router/go_router.dart';
import 'package:lottie/lottie.dart';
import 'package:shakti/state/auth/Auth_bloc.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late final theme=Theme.of(context);
  late final router=GoRouter.of(context);

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AuthBloc,AuthState>(
      buildWhen: (previous, current) => previous!=current,
      builder: (context, state) {
        return Scaffold(
          drawerEdgeDragWidth: 100,
          drawerEnableOpenDragGesture: true,
          drawerScrimColor: Colors.black54,
          drawer: Drawer(
            shape: BeveledRectangleBorder(),
            elevation: 5,
            child: Text("data"),
          ),
          appBar: AppBar(
            leading: Builder(
              builder: (context) => IconButton(
                icon: const Icon(Icons.menu,color: Colors.white), // Custom icon
                onPressed: () =>Scaffold.of(context).openDrawer(),
              ),
            ),
            backgroundColor: theme.primaryColor.withRed(200),
            actions: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8.0),
                child: GestureDetector(
                  onTap: () => router.pushNamed(AppRoutes.settings.name),
                  child: CircleAvatar(
                    radius: 20,
                    child:state.userInfo?.profileUrl!=null ? ClipOval(child: Image.network(fit: BoxFit.cover,state.userInfo!.profileUrl!,errorBuilder: (context, error, stackTrace) => Icon(Icons.error),loadingBuilder: (context, child, loadingProgress) => loadingProgress!=null ? SpinKitWaveSpinner(color: Colors.green) : child)) : Icon(FontAwesomeIcons.user,color: theme.primaryColor),
                  ),
                ),
              )
            ],
          ),
          body: SafeArea(child: Column(
            children: [
              FilledButton(onPressed: () => router.pushNamed(AppRoutes.player.name), child: Text("Play"))
            ],
          )),
        );
      },
    );
  }
}

