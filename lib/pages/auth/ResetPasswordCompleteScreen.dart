import 'package:shakti/routes.dart';
import 'package:shakti/singletons/NotificationService.dart';
import 'package:shakti/state/HttpStates.dart';
import 'package:shakti/widgets/CustomElevatedButton.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../state/auth/Auth_bloc.dart';
import '../../widgets/CustomInputField.dart';
import '../../widgets/OtpField.dart';

class ResetPasswordCompleteScreen extends StatefulWidget {
  const ResetPasswordCompleteScreen({super.key});

  @override
  State<ResetPasswordCompleteScreen> createState() => _ResetPasswordCompleteScreenState();
}

class _ResetPasswordCompleteScreenState extends State<ResetPasswordCompleteScreen> {
  final formKey = GlobalKey<FormState>(debugLabel: 'resetPassword');
  late final authBlock=BlocProvider.of<AuthBloc>(context);
  final TextEditingController newPasswordCntrl = TextEditingController(text: '');
  final TextEditingController confirmPasswordCntrl = TextEditingController(text: '');
  final List<FocusNode> _focusNodes=List.generate(6, (index) => FocusNode());
  final List<TextEditingController> _otpcontrollers=List.generate(6, (index) => TextEditingController());
  final CancelToken cancelToken = CancelToken();

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<AuthBloc, AuthState>(
        listenWhen: (previous, current) => isStateChanged(previous,current),
        listener: (ctx, state) {
          if(state.isExpired(forr: HttpStates.RESET_PASSWORD)) return;
          if (state.isSuccess(forr: HttpStates.RESET_PASSWORD)) {
            NotificationService.showSnackbar(text:"password reset successfully",color: Colors.green);
            context.goNamed(AppRoutes.login.name);
            return;
          }else if(state.isError(forr: HttpStates.RESET_PASSWORD)){
            NotificationService.showSnackbar(text:state.getError(forr: HttpStates.RESET_PASSWORD)!,color: Colors.red);
          }
        },
        buildWhen: (previous, current) => isStateChanged(previous,current),
        builder: (context, state) => Scaffold(
          appBar: AppBar(
            title: const Text(
              'Reset Password',
              style: TextStyle(color: Colors.white, fontFamily: "oxanium", fontSize: 24, fontWeight: FontWeight.bold),
            ),
            elevation: 10,
            backgroundColor: Theme.of(context).primaryColor,
            iconTheme: const IconThemeData(color: Colors.white),
          ),
          body: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(18.5),
              child: Form(
                key: formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  mainAxisSize: MainAxisSize.max,
                  children: [
                    OtpField(otpcontrollers: _otpcontrollers, focusNodes: _focusNodes),
                    const SizedBox(height: 7),
                    CustomInputField(
                        controller: newPasswordCntrl,
                        labelText: "New Password",
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter New Password';
                          }
                          return null;
                        }),
                    const SizedBox(
                      height: 7,
                    ),
                    CustomInputField(
                        controller: confirmPasswordCntrl,
                        labelText: "Confirm Password",
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter Confirm Password';
                          }
                          return null;
                        }),
                    const SizedBox(
                      height: 7,
                    ),
                    CustomElevatedButton(
                      isLoading: state.isLoading(forr: HttpStates.RESET_PASSWORD),
                      onPressed: () {
                        if (formKey.currentState?.validate() == false) {
                          return;
                        }
                        authBlock.add(ResetPasswordEvent(usernameEmail: state.userInfo!.email,otp: _otpcontrollers.map((c) => c.text.trim()).where((num) => num.isNotEmpty).join(''), password: newPasswordCntrl.value.text, confirmPassword: confirmPasswordCntrl.value.text, cancelToken: cancelToken));
                      },
                      child: const Text(
                        'Update Password',
                        style: TextStyle(color: Colors.white, fontSize: 18),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ));
  }

  @override
  void dispose() {
    cancelToken.cancel("reset password complete cancelled");
    super.dispose();
  }

  bool isStateChanged(AuthState previous, AuthState current) {
    return previous.httpStates[HttpStates.RESET_PASSWORD]!=current.httpStates[HttpStates.RESET_PASSWORD];
  }
}
