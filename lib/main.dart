import 'dart:async';

import 'package:flutter/material.dart';
import 'package:shakti/pages/AartiScreen.dart';
import 'package:shakti/pages/auth/LoginScreen.dart';
import 'package:shakti/pages/SettingsScreen.dart';
import 'package:shakti/pages/ShaktiReelsScreen.dart';
import 'package:shakti/pages/SplashScreen.dart';
import 'package:shakti/pages/auth/ReVerifyScreen.dart';
import 'package:shakti/pages/auth/RegisterScreen.dart';
import 'package:shakti/pages/auth/ResetPasswordCompleteScreen.dart';
import 'package:shakti/pages/auth/ResetPasswordInitScreen.dart';
import 'package:shakti/pages/auth/UpdatePasswordScreen.dart';
import 'package:shakti/pages/auth/profileScreen.dart';
import 'package:shakti/routes.dart';
import 'package:shakti/services/AartiApi.dart';
import 'package:shakti/services/AuthApi.dart';
import 'package:shakti/services/ShaktiReelApi.dart';
import 'package:shakti/singletons/NotificationService.dart';
import 'package:shakti/state/aarti/Aarti_bloc.dart';
import 'package:shakti/state/auth/Auth_bloc.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:shakti/state/shaktiReels/ShaktiReel_bloc.dart';
import 'package:shakti/streams/auth-global-dispatcher.dart';

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
  static final List<String> _whiteListedUrls= [
    AppRoutes.splashRoute.fullPath,
    AppRoutes.login.fullPath,
    AppRoutes.resetPasswordInit.fullPath,
    AppRoutes.resetPasswordComplete.fullPath,
    AppRoutes.registerUser.fullPath,
    AppRoutes.reverifyAccount.fullPath,
  ];

  StreamSubscription<GlobalEvent>? globalEventSubscription;

  final router=GoRouter(
      debugLogDiagnostics: true,
      initialLocation: AppRoutes.splashRoute.path,
      redirect: (context, state) {
        if(_whiteListedUrls.contains(state.fullPath)) return null;
        final userInfo=BlocProvider.of<AuthBloc>(context).state.userInfo;
        if(userInfo==null) return AppRoutes.login.fullPath;
        return null;
      },
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
          name: AppRoutes.auth.name,
          path: AppRoutes.auth.path,
          redirect: (context, state) {
            if(state.fullPath==AppRoutes.auth.fullPath) return AppRoutes.login.fullPath;
            return null;
          },
          routes: [
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
              name: AppRoutes.profile.name,
              path: AppRoutes.profile.path,
              pageBuilder: (context, state) => CustomTransitionPage<void>(
                key: state.pageKey,
                child: const ProfileScreen(),
                transitionsBuilder: (context, animation, secondaryAnimation, child) => FadeTransition(opacity: animation, child: child),
              ),
            ),
            GoRoute(
              name: AppRoutes.updatePassword.name,
              path: AppRoutes.updatePassword.path,
              pageBuilder: (context, state) => CustomTransitionPage<void>(
                key: state.pageKey,
                child: const UpdatePasswordScreen(),
                transitionsBuilder: (context, animation, secondaryAnimation, child) => FadeTransition(opacity: animation, child: child),
              ),
            ),
            GoRoute(
              name: AppRoutes.resetPasswordInit.name,
              path: AppRoutes.resetPasswordInit.path,
              pageBuilder: (context, state) => CustomTransitionPage<void>(
                key: state.pageKey,
                child: const ResetPasswordInitScreen(),
                transitionsBuilder: (context, animation, secondaryAnimation, child) => FadeTransition(opacity: animation, child: child),
              ),
            ),
            GoRoute(
              name: AppRoutes.resetPasswordComplete.name,
              path: AppRoutes.resetPasswordComplete.path,
              pageBuilder: (context, state){
                final usernameEmail=((state.extra ?? {}) as Map?)?['usernameEmail']!;
                return CustomTransitionPage<void>(
                  key: state.pageKey,
                  child: ResetPasswordCompleteScreen(usernameEmail: usernameEmail),
                  transitionsBuilder: (context, animation, secondaryAnimation, child) => FadeTransition(opacity: animation, child: child),
                );
              },
            ),
            GoRoute(
              name: AppRoutes.registerUser.name,
              path: AppRoutes.registerUser.path,
              pageBuilder: (context, state) => CustomTransitionPage<void>(
                key: state.pageKey,
                child: const RegisterScreen(),
                transitionsBuilder: (context, animation, secondaryAnimation, child) => FadeTransition(opacity: animation, child: child),
              ),
            ),
            GoRoute(
              name: AppRoutes.reverifyAccount.name,
              path: AppRoutes.reverifyAccount.path,
              pageBuilder: (context, state) => CustomTransitionPage<void>(
                key: state.pageKey,
                child: const ReVerifyScreen(),
                transitionsBuilder: (context, animation, secondaryAnimation, child) => FadeTransition(opacity: animation, child: child),
              ),
            )
          ]
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
        GoRoute(
          name: AppRoutes.shaktiReels.name,
          path: AppRoutes.shaktiReels.path,
          pageBuilder: (context, state) => CustomTransitionPage<void>(
            key: state.pageKey,
            child: const ShaktiReelsScreen(),
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
    globalEventSubscription=(globalEventDispatcher.stream as Stream<GlobalEvent>).listen((event) {
      if ((event is LogOutCompleteEvent)) {
        router.goNamed(AppRoutes.login.name);
      }
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<AuthBloc>(lazy: false, create: (ctx) => AuthBloc(authApi: AuthApi())),
        BlocProvider<AartiBloc>(lazy: false, create: (ctx) => AartiBloc(aartiApi: AartiApi())),
        BlocProvider<ShaktiReelBloc>(lazy: false, create: (ctx) => ShaktiReelBloc(shaktiReelApi: ShaktiReelApi()))
      ],
      child:MaterialApp.router(
        key: parentNavKey,
        scaffoldMessengerKey: NotificationService.messengerKey,
        title: 'Shakti',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          colorSchemeSeed: Colors.red,
          useMaterial3: true,
          appBarTheme: AppBarTheme(iconTheme: IconThemeData(color: Colors.white)),
          fontFamily:'monospace',
        ),
        routerConfig: router,
      ),
    );
  }

  @override
  void dispose() {
    globalEventSubscription?.cancel();
    super.dispose();
  }
}
