import 'package:flutter/material.dart';
import 'package:shakti/pages/AartiScreen.dart';
import 'package:shakti/pages/LoginScreen.dart';
import 'package:shakti/pages/SettingsScreen.dart';
import 'package:shakti/pages/SplashScreen.dart';
import 'package:shakti/routes.dart';
import 'package:shakti/services/AartiApi.dart';
import 'package:shakti/services/AuthApi.dart';
import 'package:shakti/singletons/NotificationService.dart';
import 'package:shakti/state/aarti/Aarti_bloc.dart';
import 'package:shakti/state/auth/Auth_bloc.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

final parentNavKey=GlobalKey<NavigatorState>();

void main() async{
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> with WidgetsBindingObserver {
  final router=GoRouter(
      debugLogDiagnostics: true,
      initialLocation: AppRoutes.splashRoute.path,
      routes: [
        GoRoute(
        name: AppRoutes.splashRoute.name,
        path: AppRoutes.splashRoute.path,
          pageBuilder: (context, state) => CustomTransitionPage<void>(
            key: state.pageKey,
            child: const SplashScreen(),
            transitionsBuilder: (context, animation, secondaryAnimation, child) => FadeTransition(opacity: animation, child: child),
          ),
        ),
        GoRoute(
          name: AppRoutes.login.name,
          path: AppRoutes.login.path,
          pageBuilder: (context, state) => CustomTransitionPage<void>(
            key: state.pageKey,
            child: const LoginScreen(),
            transitionsBuilder: (context, animation, secondaryAnimation, child) => FadeTransition(opacity: animation, child: child),
          ),
        ),
        GoRoute(
          name: AppRoutes.home.name,
          path: AppRoutes.home.path,
          pageBuilder: (context, state) => CustomTransitionPage<void>(
            key: state.pageKey,
            child: const AartiScreen(),
            transitionsBuilder: (context, animation, secondaryAnimation, child) => FadeTransition(opacity: animation, child: child),
          ),
        ),
        GoRoute(
          name: AppRoutes.settings.name,
          path: AppRoutes.settings.path,
          pageBuilder: (context, state) => CustomTransitionPage<void>(
            key: state.pageKey,
            child: const SettingsScreen(),
            transitionsBuilder: (context, animation, secondaryAnimation, child) => FadeTransition(opacity: animation, child: child),
          ),
        ),
        // GoRoute(
        //   name: AppRoutes.player.name,
        //   path: AppRoutes.player.path,
        //   pageBuilder: (context, state) => CustomTransitionPage<void>(
        //     key: state.pageKey,
        //     child: const AudioPlayerScreen(),
        //     transitionsBuilder: (context, animation, secondaryAnimation, child) => FadeTransition(opacity: animation, child: child),
        //   ),
        // ),
      ]);

  @override
  void initState() {
    WidgetsBinding.instance.addObserver(this);//lifecycycle events
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<AuthBloc>(lazy: false, create: (ctx) => AuthBloc(authApi: AuthApi())),
        BlocProvider<AartiBloc>(lazy: false, create: (ctx) => AartiBloc(aartiApi: AartiApi()))
      ],
      child:MaterialApp.router(
        key: parentNavKey,
        scaffoldMessengerKey: NotificationService.messengerKey,
        title: 'Shakti',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          colorSchemeSeed: Colors.red,
          useMaterial3: true,
          fontFamily:'monospace',
        ),
        routerConfig: router,
      ),
    );
  }
  @override
  void dispose() {
    super.dispose();
  }
}
