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

class UpdatePasswordScreen extends StatefulWidget {
  const UpdatePasswordScreen({super.key});

  @override
  State<UpdatePasswordScreen> createState() => _UpdatePasswordScreenState();
}

class _UpdatePasswordScreenState extends State<UpdatePasswordScreen> {
  final formKey = GlobalKey<FormState>(debugLabel: 'updatePassword');
  late final authBlock=BlocProvider.of<AuthBloc>(context);
  final TextEditingController oldPasswordCntrl = TextEditingController(text: '');
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
      listenWhen: (previous, current) => previous.httpStates[HttpStates.UPDATE_PASSWORD_COMPLETE]!=current.httpStates[HttpStates.UPDATE_PASSWORD_COMPLETE],
        listener: (ctx, state) {
          if (state.isSuccess(forr: HttpStates.UPDATE_PASSWORD_COMPLETE)) {
            NotificationService.showSnackbar(text:"updated password successfully",color: Colors.green);
            GoRouter.of(context).pop();
            return;
          }else if(state.isError(forr: HttpStates.UPDATE_PASSWORD_COMPLETE)){
            NotificationService.showSnackbar(text:state.getError(forr: HttpStates.UPDATE_PASSWORD_COMPLETE)!,color: Colors.red);
          }
        },
        buildWhen: (previous, current) => previous.httpStates[HttpStates.UPDATE_PASSWORD_COMPLETE]!=current.httpStates[HttpStates.UPDATE_PASSWORD_COMPLETE],
        builder: (context, state) => Scaffold(
              appBar: AppBar(
                title: const Text(
                  'Update Password',
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
                            controller: oldPasswordCntrl,
                            labelText: "Old Passwword",
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Please enter old Password';
                              }
                              return null;
                            }),
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
                          isLoading: state.isLoading(forr: HttpStates.UPDATE_PASSWORD_COMPLETE),
                          onPressed: () {
                                  if (formKey.currentState?.validate() == false) {
                                    return;
                                  }
                                  authBlock.add(UpdatePasswordCompleteEvent(otp: _otpcontrollers.map((c) => c.text.trim()).where((num) => num.isNotEmpty).join(''), oldPassword: oldPasswordCntrl.value.text, newPassword: newPasswordCntrl.value.text, confirmPassword: confirmPasswordCntrl.value.text, cancelToken: cancelToken));
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
    cancelToken.cancel("update cancelled");
    super.dispose();
  }
}
