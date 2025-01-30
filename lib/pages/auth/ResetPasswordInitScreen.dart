import 'package:shakti/state/HttpStates.dart';
import 'package:shakti/widgets/CustomElevatedButton.dart';
import 'package:shakti/widgets/CustomInputField.dart';
import 'package:shakti/widgets/CustomTextButton.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../routes.dart';
import '../../singletons/NotificationService.dart';
import '../../state/auth/Auth_bloc.dart';

class ResetPasswordInitScreen extends StatefulWidget {
  const ResetPasswordInitScreen({super.key});

  @override
  State<ResetPasswordInitScreen> createState() => _ResetPasswordInitScreenState();
}

class _ResetPasswordInitScreenState extends State<ResetPasswordInitScreen> {
  final CancelToken cancelToken = CancelToken();
  final formKey = GlobalKey<FormState>(debugLabel: 'loginForm');
  late final authBloc=BlocProvider.of<AuthBloc>(context);
  final TextEditingController usernameEmailController = TextEditingController(text: '');

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<AuthBloc, AuthState>(
      listenWhen: (previous, current) => isStateChanged(previous,current),
      listener: (ctx, state) {
        if(state.isExpired(forr: HttpStates.FORGOT_PASSWORD)) return;
        authBloc.add(ExpireHttpState(forr: HttpStates.FORGOT_PASSWORD));
        if (state.isError(forr: HttpStates.FORGOT_PASSWORD)) {
          NotificationService.showSnackbar(text: state.getError(forr: HttpStates.FORGOT_PASSWORD)!, color: Colors.red);
        }else if(state.isSuccess(forr: HttpStates.FORGOT_PASSWORD)){
          NotificationService.showSnackbar(text: state.httpStates[HttpStates.FORGOT_PASSWORD]?.value ?? 'Otp sent successfully', color: Colors.green);
          context.replaceNamed(AppRoutes.resetPasswordComplete.name,extra: {'usernameEmail':usernameEmailController.text.trim()});
        }
      },
      buildWhen: (previous, current) => isStateChanged(previous,current),
      builder: (context, state) {
        return Scaffold(
          appBar: AppBar(
            title: const Text('Forgot Password', style: TextStyle(color: Colors.white, fontFamily: "oxanium", fontSize: 24, fontWeight: FontWeight.bold)),
            backgroundColor: Theme.of(context).primaryColor,
            elevation: 10,
          ),

          body: PopScope(canPop: false,onPopInvokedWithResult: (didPop, result) {
            if(!mounted) return;
            if(state.isLoading(forr: HttpStates.FORGOT_PASSWORD)){
              NotificationService.showSnackbar(text: "Please wait, we are processing your request",color: Colors.red);
              return;
            }
            if(context.canPop()) context.pop();
          },child: Padding(
            padding: const EdgeInsets.all(15),
            child: Center(
              child: Form(
                key: formKey,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    CustomInputField(
                        enabled: !state.isLoading(forr: HttpStates.FORGOT_PASSWORD),
                        controller: usernameEmailController,
                        labelText: 'Username/Email',
                        hintText: 'xyz/xyz@gmail.com',
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return "Please enter username/email";
                          }
                          return null;
                        }),
                    const SizedBox(height: 12),
                    CustomElevatedButton(
                        isLoading: state.isLoading(forr: HttpStates.FORGOT_PASSWORD),
                        onPressed: () {
                          if (!formKey.currentState!.validate()) return;
                          authBloc.add(ForgotPasswordEvent(usernameEmail: usernameEmailController.text,cancelToken: cancelToken));
                        },
                        child: Text('Forgot-password', style: TextStyle(color: state.isLoading(forr: HttpStates.FORGOT_PASSWORD) ? Colors.grey : Colors.white, fontSize: 18),)),
                    const SizedBox(height: 12),
                    CustomTextButton(isDisabled: state.isLoading(forr: HttpStates.FORGOT_PASSWORD),onPressed: () => context.goNamed(AppRoutes.login.name), child: const Text('Sign-in instead'))
                  ],
                ),
              ),
            ),
          )),
        );
      },
    );
  }

  @override
  void dispose() {
    cancelToken.cancel("reset cancelled");
    super.dispose();
  }

  bool isStateChanged(AuthState previous, AuthState current) {
    return previous.httpStates[HttpStates.FORGOT_PASSWORD]!=current.httpStates[HttpStates.FORGOT_PASSWORD];
  }
}
