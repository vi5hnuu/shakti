import 'package:shakti/routes.dart';
import 'package:shakti/state/HttpStates.dart';
import 'package:shakti/widgets/CustomElevatedButton.dart';
import 'package:shakti/widgets/CustomTextButton.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../singletons/NotificationService.dart';
import '../../state/auth/Auth_bloc.dart';
import '../../widgets/CustomInputField.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final formKey = GlobalKey<FormState>(debugLabel: 'registerForm');
  final TextEditingController firstNameCntrl = TextEditingController(text: '');
  final TextEditingController lastNameCntrl = TextEditingController(text: '');
  final TextEditingController usernameControllerCntrl = TextEditingController(text: '');
  final TextEditingController emailCntrl = TextEditingController(text: '');
  final TextEditingController passwordCntrl = TextEditingController(text: '');
  late final authBlock=BlocProvider.of<AuthBloc>(context);
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
          if(state.isExpired(forr: HttpStates.REGISTER)) return;
          authBlock.add(ExpireHttpState(forr: HttpStates.REGISTER));
          if (state.isSuccess(forr: HttpStates.REGISTER)) {
            NotificationService.showSnackbar(text: state.message ?? state.httpStates[HttpStates.REGISTER]?.value ?? "Check your email to verify account",color: Colors.green);
            context.goNamed(AppRoutes.login.name);
          }else if(state.isError(forr: HttpStates.REGISTER)){
            NotificationService.showSnackbar(text:state.getError(forr: HttpStates.REGISTER)!,color: Colors.red);
          }
        },
        buildWhen: (previous, current) =>  isStateChanged(previous,current),
        builder: (context, state) => Scaffold(
              appBar: AppBar(
                title: const Text(
                  'Registration',
                  style: TextStyle(color: Colors.white, fontFamily: "Kalam", fontSize: 32, fontWeight: FontWeight.bold),
                ),
                centerTitle: true,
                elevation: 10,
                backgroundColor: Theme.of(context).primaryColor,
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
                        CustomInputField(
                          enabled: !state.isLoading(forr: HttpStates.REGISTER),
                            controller: firstNameCntrl,
                            hintText: "vishnu",
                            labelText: "First Name",
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Please enter first name';
                              }
                              return null;
                            }),
                        const SizedBox(
                          height: 7,
                        ),
                        CustomInputField(
                            enabled: !state.isLoading(forr: HttpStates.REGISTER),
                            controller: lastNameCntrl,
                            hintText: "kumar",
                            labelText: "Last Name",
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Please enter last name';
                              }
                              return null;
                            }),
                        const SizedBox(
                          height: 7,
                        ),
                        CustomInputField(
                            enabled: !state.isLoading(forr: HttpStates.REGISTER),
                            controller: usernameControllerCntrl,
                            hintText: "vi5hnu",
                            labelText: "Username",
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Please enter username';
                              }
                              return null;
                            }),
                        const SizedBox(
                          height: 7,
                        ),
                        CustomInputField(
                            enabled: !state.isLoading(forr: HttpStates.REGISTER),
                            controller: emailCntrl,
                            hintText: "xyz@gmail.com",
                            labelText: "Email",
                            suffixIcon: const Icon(Icons.email_outlined),
                            validator: (value) {
                              if (value == null || !value.contains("@gmail.com")) {
                                return 'Please enter valid email id';
                              }
                              return null;
                            }),
                        const SizedBox(
                          height: 7,
                        ),
                        CustomInputField(
                            enabled: !state.isLoading(forr: HttpStates.REGISTER),
                            controller: passwordCntrl,
                            obscureText: true,
                            hintText: "as4c45a65s",
                            labelText: "password",
                            suffixIcon: const Icon(Icons.password),
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Please enter valid password';
                              }
                              return null;
                            }),
                        const SizedBox(
                          height: 18,
                        ),
                        CustomElevatedButton(
                          isLoading: state.isLoading(forr: HttpStates.REGISTER),
                            onPressed: () {
                                    if (formKey.currentState?.validate() == false) {
                                      return;
                                    }
                                    BlocProvider.of<AuthBloc>(context).add(RegisterEvent(
                                        firstName: firstNameCntrl.text,
                                        lastName: lastNameCntrl.text,
                                        username: usernameControllerCntrl.text,
                                        email: emailCntrl.text,
                                        password: passwordCntrl.text,
                                        cancelToken: cancelToken));
                                  },
                            child: const Text('Register', style: TextStyle(color: Colors.white, fontSize: 18))),
                        const SizedBox(height: 12),
                        CustomTextButton(
                          isDisabled: state.isLoading(forr: HttpStates.REGISTER),
                            onPressed: () => GoRouter.of(context).goNamed(AppRoutes.login.name),
                            child: const Text('Sign-in instead')),
                      ],
                    ),
                  ),
                ),
              ),
            ));
  }

  @override
  void dispose() {
    cancelToken.cancel("register cancelled");
    super.dispose();
  }

  bool isStateChanged(AuthState previous, AuthState current) {
    return previous.httpStates[HttpStates.REGISTER]!=current.httpStates[HttpStates.REGISTER];
  }
}
