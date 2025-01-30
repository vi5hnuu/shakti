import 'package:flutter/scheduler.dart';
import 'package:shakti/singletons/NotificationService.dart';
import 'package:shakti/state/HttpStates.dart';
import 'package:shakti/widgets/CustomElevatedButton.dart';
import 'package:shakti/widgets/CustomInputField.dart';
import 'package:shakti/widgets/CustomTextButton.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../routes.dart';
import '../../state/auth/Auth_bloc.dart';

class ReVerifyScreen extends StatefulWidget {
  const ReVerifyScreen({super.key});

  @override
  State<ReVerifyScreen> createState() => _ReVerifyScreenState();
}

class _ReVerifyScreenState extends State<ReVerifyScreen> {
  final CancelToken cancelToken = CancelToken();
  late final authBloc=BlocProvider.of<AuthBloc>(context);
  final formKey = GlobalKey<FormState>(debugLabel: 'loginForm');
  final TextEditingController emailCntrl = TextEditingController(text: '');

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<AuthBloc, AuthState>(
      listenWhen: (previous, current) => previous != current,
      listener: (ctx, state) {
        if(state.isExpired(forr: HttpStates.REVERIFY)) return;
        authBloc.add(ExpireHttpState(forr: HttpStates.REVERIFY));
        if (state.isSuccess(forr: HttpStates.REVERIFY)) {
          NotificationService.showSnackbar(text: state.message ?? state.httpStates[HttpStates.REVERIFY]?.value ?? "Check your email to verify account",color: Colors.green);
          SchedulerBinding.instance.addPostFrameCallback((timeStamp) => context.goNamed(AppRoutes.login.name));
        }else if(state.isError(forr: HttpStates.REVERIFY)){
          NotificationService.showSnackbar(text:state.getError(forr: HttpStates.REVERIFY)!,color: Colors.red);
        }
        // if (state.success) {
        //   NotificationService.showSnackbar(text: state.message ?? "verified successfully", color: Colors.green);
        //   context.goNamed(AppRoutes.login.name);
        // }
        if (state.isError(forr: HttpStates.REVERIFY)) {
          NotificationService.showSnackbar(text: state.message ?? "verification failed", color: Colors.red);
        }
      },
      builder: (context, state) => Scaffold(
        appBar: AppBar(
          title: const Text(
            'Account Verification',
            style: TextStyle(color: Colors.white, fontFamily: "oxanium", fontSize: 24, fontWeight: FontWeight.bold),
          ),
          backgroundColor: Theme.of(context).primaryColor,
          elevation: 10,
        ),
        body: PopScope(
          canPop: false,
          onPopInvokedWithResult: (didPop, result) {
            if(!mounted) return;
            if(state.isLoading(forr: HttpStates.REVERIFY)){
              NotificationService.showSnackbar(text: "Please wait, we are processing your request",color: Colors.red);
              return;
            }
            if(context.canPop()) context.pop();
          },
          child: Padding(
            padding: const EdgeInsets.all(15),
            child: Center(
              child: Form(
                key: formKey,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    CustomInputField(
                      controller: emailCntrl,
                      labelText: 'Email',
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return "Please enter email";
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 18),
                    CustomElevatedButton(
                      isLoading:state.isLoading(forr: HttpStates.REVERIFY),
                        onPressed: () => BlocProvider.of<AuthBloc>(context).add(ReVerifyEvent(email: this.emailCntrl.value.text, cancelToken: cancelToken)),
                        child: const Text(
                          "send verification email",
                          style: TextStyle(color: Colors.white),
                        )),
                    const SizedBox(height: 12),
                    CustomTextButton(isDisabled: state.isLoading(forr: HttpStates.REVERIFY),onPressed:() => context.goNamed(AppRoutes.login.name), child: const Text('login instead')),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    cancelToken.cancel("login cancelled");
    super.dispose();
  }
}
