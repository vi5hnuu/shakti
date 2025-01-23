import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shakti/routes.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:go_router/go_router.dart';
import 'package:lottie/lottie.dart';
import 'package:shakti/state/auth/Auth_bloc.dart';
import 'package:url_launcher/url_launcher.dart';

import '../singletons/SecureStorage.dart';
import '../state/httpStates.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  late final authBloc=BlocProvider.of<AuthBloc>(context);
  late final router=GoRouter.of(context);
  Timer? timer;
  var adsInitilized=false;

  @override
  void initState() {
    authBloc.add(TryAuthenticatingEvent());
    timer=Timer(const Duration(seconds: 5),(){
      if(!mounted) return;
      if(authBloc.state.isSuccess(forr: HttpStates.TRY_AUTH)) router.goNamed(AppRoutes.home.name);
      else if(authBloc.state.isError(forr: HttpStates.TRY_AUTH)) router.goNamed(AppRoutes.login.name);
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final theme=Theme.of(context);
    final mq=MediaQuery.of(context);

    return Scaffold(
        body:BlocConsumer<AuthBloc,AuthState>(
          listenWhen: (previous, current) => previous.httpStates[HttpStates.TRY_AUTH]!=current.httpStates[HttpStates.TRY_AUTH],
          buildWhen: (previous, current) => previous.httpStates[HttpStates.TRY_AUTH]!=current.httpStates[HttpStates.TRY_AUTH],
          listener: (context, state) {
            if(timer?.isActive==true) return;
            if(state.isError(forr: HttpStates.TRY_AUTH)){
              router.goNamed(AppRoutes.login.name);
            } else if(state.isSuccess(forr: HttpStates.TRY_AUTH)){
              router.goNamed(AppRoutes.home.name);
            }
          },builder: (context, state) {
          return Stack(
            fit: StackFit.expand,
            children: [
              Positioned(left: 0,right: 0, child: Row(
                mainAxisSize: MainAxisSize.max,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  LottieBuilder.asset("assets/lottie/diwali-lantern.json",fit: BoxFit.fitWidth,width: mq.size.width*0.35,animate: true,backgroundLoading: true,),
                  LottieBuilder.asset("assets/lottie/diwali-lantern.json",fit: BoxFit.fitWidth,width: mq.size.width*0.35,animate: true,backgroundLoading: true,)
                ],
              )),
              Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      width: double.infinity,
                      margin: const EdgeInsets.symmetric(horizontal: 75,vertical: 125),
                      child:LottieBuilder.asset("assets/lottie/diwali-rangoli.json",fit: BoxFit.fitWidth,animate: true,backgroundLoading: true,),
                    ),
                    Column(
                      children: [
                        const SizedBox(height: 15),
                        SpinKitFadingCube(color: theme.primaryColor.withRed(255),size: 32,)
                      ],
                    ),
                  ],
                ),
              ),
              Align(
                  alignment: Alignment.bottomCenter,
                  child: GestureDetector(
                    onTap: openLinkedin,
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        LottieBuilder.asset("assets/lottie/linkedin.json",height: 32,animate: true,backgroundLoading: true,),
                        SizedBox(width:8,),
                        Text("@vi5hnukumar",style: TextStyle(color: Colors.blue.shade900,fontWeight: FontWeight.bold,fontFamily: "oxanium",fontSize: 16),)
                      ],
                    ),
                  ))
            ],
          );
        },));
  }

  Future<void> openLinkedin() async {//launch in app and fallback to browser else error
    try {
      final uri=Uri.parse("https://www.linkedin.com/in/vi5hnukumar/");
      if (!await launchUrl(uri, mode: LaunchMode.externalApplication) || !await launchUrl(uri, mode: LaunchMode.inAppBrowserView)) {
        throw Exception('Could not launch linkedin');
      }
    } catch (e) {
      print(e);
    }
  }

  @override
  void dispose() {
    timer?.cancel();
    super.dispose();
  }
}
